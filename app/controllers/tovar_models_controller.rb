# == Schema Information
#
# Table name: tovar_models
#
#  id            :integer          not null, primary key
#  tovar_id      :integer
#  content_name  :string(255)
#  content_text  :text
#  del           :boolean
#  row_num       :integer
#  price         :float
#  use_in_new    :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  currency      :integer          default(0)
#  popular_model :boolean          default(FALSE)
#  in_stock      :boolean          default(TRUE)
#  pre_order     :boolean          default(FALSE)
#  unit          :string(255)
#  quantity      :string(255)
#

class TovarModelsController < GenericController
  load_and_authorize_resource

  before_filter :check_row_num, only: :index
  before_filter :params_values_strip, only: [:create, :update]
  before_filter :set_actions, if: proc { current_user&.admin_less? }

  def index
    if current_user&.admin_less? && admin_view?
      if params[:tovar_id]
        @tovar_models = TovarModel.where(tovar_id: params[:tovar_id]).ordering.page(params[:page])
        @list_pages = Admin::ListPages.new do |l|
          l.controller_name = controller_name
          l.action_name = action_name
          l.list = @tovar_models
        end
        render 'admin_index'
      else
        redirect_to root_path, alert: 'Ошибка определения товара для списка моделей.'
      end
    else
      redirect_to root_path
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if @tovar_model.blank?

    redirect_to @tovar_model.tovar
  end

  def new
    tovar = Tovar.where(id: params[:tovar_id]).first
    if tovar.blank?
      flash[:error] = 'Товар не найден. Возможно он был удален.'
      redirect_to request.referer || root_path
    else
      new_model_hash = { tovar_id: tovar.id, use_in_new: false }
      if tovar.tovar_models.blank?
        prop = tovar.tovars_properties.inject({}){|h,el| h.merge(h.size => {:property_type_id => el.property_type_id})}
        new_model_hash.merge!(tovar_models_properties_attributes: prop)
      else
        model = tovar.tovar_models.last
        prop = model.tovar_models_properties.inject({}) do |h,el|
          h.merge(h.size => { property_type_id: el.property_type_id,
                              value: el.value })
        end
        new_model_hash.merge!(tovar_models_properties_attributes: prop, currency: model.currency, price: model.price)
      end

      @tovar_model = TovarModel.new(new_model_hash)
      render 'new_edit'
    end
  end

  def edit
    super
  end

  def create
    super
  end

  def update
    super
  end

  def destroy
    @tovar_model.destroy

    respond_to do |format|
      format.html { redirect_to tovar_url(@tovar_model.tovar) }
      format.json { render json: @tovar_model }
    end
  end

  def yandex_market_form
    if @tovar_model.yandex_market.blank?
      tovar = @tovar_model.tovar
      @tovar_model.build_yandex_market(description: tovar.section.to_s, model_name: tovar.to_s)
    end
  end

  private

  def check_row_num
    row_num_record = Admin::RowNum::Fix.new(:tovar_model, nil, tovar_id: params[:tovar_id])
    if !params[:cancel_check_row_num] && row_num_record.need_check?
      redirect_to template_system.admin_edit_fix_row_num_url(:tovar_model, model_module: nil, opt: { tovar_id: params[:tovar_id] })
    end
  end

  def params_values_strip
    if params[:tovar_model]
      params[:tovar_model].each { |_k, v| v.strip! if v.is_a?(String) }
      if params[:tovar_model][:tovar_models_properties_attributes]
        params[:tovar_model][:tovar_models_properties_attributes].each { |_k, v1| v1.each { |_k, v| v.strip! }}
      end
    end
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@tovar_model || ::TovarModel)
    @admin_panel.default_namespace = ''
    @admin_panel.from(controller_name, action_name)
    @tovar = (@tovar_model || @tovar_models.first).tovar
    @tovar_id = params[:tovar_id] || @tovar&.id
  end
end

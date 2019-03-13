class TovarsPropertiesController < ApplicationController
  load_and_authorize_resource

  before_filter :check_row_num, only: :index, if: proc { current_user&.admin_less? }
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  def index
    if current_user&.admin_less? && admin_view?
      @list_pages = Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = TovarsProperty.where(tovar_id: params[:tovar_id]).order(:row_num).page(params[:page])
      end
      respond_to do |format|
        format.html { render 'admin_index' }
        format.json { render json: @list_pages }
      end
    else
      redirect_to root_path
    end
  end

  def show
    redirect_to(root_path) unless current_user&.admin_less?
  end

  private

  def check_row_num
    row_num_record = Admin::RowNum::Fix.new(:tovars_property, nil, tovar_id: params[:tovar_id])
    if !params[:cancel_check_row_num] && row_num_record.need_check?
      redirect_to template_system.admin_edit_fix_row_num_url(:tovars_property, model_module: nil, opt: { tovar_id: params[:tovar_id] })
    end
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(TovarsProperty, namespace: '')
    @admin_panel.model_engine = :main_app
    @admin_panel.from(controller_name, action_name)
  end
end

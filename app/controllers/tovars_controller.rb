# frozen_string_literal: false

# == Schema Information
#
# Table name: tovars
#
#  id              :integer          not null, primary key
#  content_name    :string(255)
#  content_header  :string(255)
#  row_num         :integer
#  del             :boolean
#  id_str          :string(70)
#  section_id      :integer
#  price           :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  popular_product :boolean
#

class TovarsController < ApplicationController
  load_and_authorize_resource

  before_filter :check_row_num, only: :index, if: proc { current_user&.admin_less? }
  before_filter :set_actions, if: proc { current_user&.admin_less? }
  before_filter :fix_tovars_properties_attributes, only: %i[create update], if: proc { params[:tovar][:tovars_properties_attributes] }

  def index
    if current_user&.admin_less? && admin_view?
      @tovars = if params[:section_id]
                  tovars = Tovar.where(section_id: params[:section_id]).ordering
                  tovars = tovars.where(discontinued: true) if params['discontinued'] == 'true'
                  tovars = tovars.where(del: true) if params['del'] == 'true'
                  tovars = tovars.where(in_stock: false) if params['in_stock'] == 'false'
                  tovars.page(params[:page])
                else
                  []
                end
      @list_pages = Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = @tovars
      end
      render 'admin_index'
    else
      redirect_to root_path
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if @tovar.blank?

    if @tovar.discontinued
      redirect_to @tovar.section
    else
      @tovar.show_card = true
      @title = @tovar.content_header
      @banner = @tovar.banner

      respond_to do |format|
        format.html { render 'show' }
      end
    end
  end

  def new
    @tovar = Tovar.new(section_id: params[:section_id])
    @tovar.build_image
    @tovar.build_annotate
    render 'new_edit'
  end

  def edit
    @tovar.build_image if @tovar.image.blank?
    @tovar.build_annotate if @tovar.annotate.blank?
    render 'new_edit'
  end

  def create
    @tovar = Tovar.new(params[:tovar])

    respond_to do |format|
      if @tovar.save
        format.html { redirect_to tovar_url(@tovar), notice: view_context.h_flash_msg(:create) }
      else
        format.html { render action: :edit, template: '/application/new_edit' }
      end
    end
  end

  def update
    respond_to do |format|
      if @tovar.update_attributes(params[:tovar])
        format.html { redirect_to tovar_url(@tovar), notice: view_context.h_flash_msg(:update) }
      else
        format.html { render action: :edit, template: '/application/new_edit' }
      end
    end
  end

  def destroy
    @tovar.destroy

    respond_to do |format|
      format.html { redirect_to section_url(@tovar.section) }
      format.json { render json: @tovar }
    end
  end

  def new_mass
    @tovar = Tovar.where(id: params[:tovar_id]).first
    @properties = @tovar.property_types
  end

  def create_mass
    tovar = Tovar.where(id: params[:r_id]).first
    properties_id = params[:tovar_properties].split.map(&:to_i)
    properties_size = properties_id.size
    row_num = tovar.tovar_models.size
    params[:list_models].lines.each_with_index do |model, i|
      model = model.split(' - ')
      model.map(&:strip!)
      if params[:without_vendor_code] == '1'
        hash_model = {}
        offset = 0
      else
        hash_model = { content_name: model[0] }
        offset = 1
      end
      hash_model.merge!(price: model[properties_size + offset].to_s.gsub(',', '.'), currency: model[properties_size + offset + 1],
                        row_num: row_num + i + 1, tovar_models_properties_attributes: {})
      properties_id.to_enum.with_index(offset).each do |id, i|
        hash_model[:tovar_models_properties_attributes].merge!(i => { property_type_id: id, value: model[i] })
      end
      tovar.tovar_models.build(hash_model)
    end
    if tovar.save!
      redirect_to tovar_url(tovar)
    else
      render action: :new_mass
    end
  end

  def copy
    tovar = Tovar.where(id: params[:tovar_id]).first
    new_hash = { section_id: tovar.section_id, content_name: tovar.content_name, content_header: tovar.content_header,
                 row_num: tovar.section.tovars.size + 1 }
    prop = tovar.tovars_properties.inject({}) do |h, el|
      h.merge(h.size => {
        property_type_id: el.property_type_id,
        filter_prop: el.filter_prop,
        similar_prop: el.similar_prop
      })
    end
    new_hash[:tovars_properties_attributes] = prop

    @tovar = Tovar.new(new_hash)
    @tovar.build_image

    render 'new_edit'
  end

  private

  def check_row_num
    row_num_record = Admin::RowNum::Fix.new(:tovar, nil, section_id: params[:section_id])
    if !params[:cancel_check_row_num] && row_num_record.need_check?
      redirect_to template_system.admin_edit_fix_row_num_url(:tovar, model_module: nil, opt: { section_id: params[:section_id] })
    end
  end

  def fix_tovars_properties_attributes
    params[:tovar][:tovar_models_attributes] = {}
    params[:tovar][:tovars_properties_attributes].each do |prm|
      if prm[1]['property_type_id'].blank?
        prm[1]['_destroy'] = true
      elsif prm[1]['_destroy'] == false.to_s
        prop = prm[1]['property_type_id'].split(',')
        if prop.size >= 1 && prop[0].to_s.length != prop[0].to_i.to_s.length
          prop[1] = PropertyType.create(content_name: prm[1][:property_type_id].gsub(/\A\d*,\s*/, '').strip).id
        end
        prm[1]['property_type_id'] = prop[1].nil? ? prop[0].to_s : prop[1].to_s
      end
    end
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@tovar || ::Tovar)
    @admin_panel.default_namespace = ''
    @admin_panel.from(controller_name, action_name)
    @section_id = params[:section_id] || @tovar&.section_id
    @tovar_models_one = @tovar&.models_count == 1
    @pages_banner_args = { root_type: 'Tovar', root_id: @tovar&.id }
  end
end

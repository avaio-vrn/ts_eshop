class Properties::TypesValuesController < ApplicationController
  load_and_authorize_resource class: 'Properties::TypesValues'

  # before_filter :check_row_num, only: :index, if: proc { current_user&.admin_less? }
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  def index
    if current_user&.admin_less? && admin_view?
      @list_pages = ::Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = ::Properties::TypesValues.by_params(params['properties_types_values']).ordering.page(params[:page])
      end
      respond_to do |format|
        format.html { render 'admin_index' }
        format.json { render json: @list_pages }
      end
    else
      redirect_to root_path
    end
  end

  def new
    @types_value = ::Properties::TypesValues.new(params[:properties_types_values])
    render 'new_edit'
  end

  def edit
    render "new_edit"
  end

  def create
    @types_value = ::Properties::TypesValues.new(params[:properties_types_values])

    respond_to do |format|
      if @types_value.save
        format.html { redirect_to properties_types_values_url(
          properties_types_values: {
            root_type: @types_value.root_type,
            root_id: @types_value.root_id
          })
        }
      else
        format.html { render action: "new", template: "application/new_edit" }
      end
    end
  end

  def update
    respond_to do |format|
      if @types_value.update_attributes(params[:properties_types_values])
        format.html { redirect_to properties_types_values_url(
          properties_types_values: {
            root_type: @types_value.root_type,
            root_id: @types_value.root_id
          })
        }
      else
        format.html { render action: "edit", template: "new_edit" }
      end
    end
  end

  def destroy
    @types_value.destroy

    respond_to do |format|
      format.html { redirect_to properties_types_values_url(
        properties_types_values: {
          root_type: @types_value.root_type,
          root_id: @types_value.root_id
        })
      }
      format.json { render json: @types_value }
    end
  end

  private

  def check_row_num
    hash = { root_type: params[:root_type], root_id: params[:root_id], type_id: params[:type_id] }
    row_num_record = Admin::RowNum::Fix.new(::Properties::TypesValues, nil, hash)
    if !params[:cancel_check_row_num] && row_num_record.need_check?
      redirect_to template_system.admin_edit_fix_row_num_url(::Properties::TypesValues, model_module: nil, opt: hash)
    end
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@types_value || ::Properties::TypesValues, namespace: 'properties', model_engine: 'main_app')
    @root_hash = { root_type: params.dig('properties_types_values', 'root_type'),
                          root_id: params.dig('properties_types_values', 'root_id') }
    @admin_panel.from(controller_name, action_name)
  end
end

class Properties::RootsTypesController < ApplicationController
  load_and_authorize_resource class: 'Properties::RootsTypes'

  # before_filter :check_row_num, only: :index, if: proc { current_user&.admin_less? }
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  def index
    if current_user&.admin_less? && admin_view?
      @list_pages = ::Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = ::Properties::RootsTypes.by_params(params['properties_roots_types']).ordering.page(params[:page])
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
    @roots_type = ::Properties::RootsTypes.new(params[:properties_roots_types])
    render 'new_edit'
  end

  def edit
    render "new_edit"
  end

  def create
    @roots_type = ::Properties::RootsTypes.new(params[:properties_roots_types])

    respond_to do |format|
      if @roots_type.save
        format.html { redirect_to properties_roots_types_url(
          properties_roots_types: {
            root_type: @roots_type.root_type,
            root_id: @roots_type.root_id
          })
        }
      else
        format.html { render action: "new", template: "application/new_edit" }
      end
    end
  end

  def update
    respond_to do |format|
      if @roots_type.update_attributes(params[:properties_roots_types])
        format.html { redirect_to properties_roots_types_url(
          properties_roots_types: {
            root_type: @roots_type.root_type,
            root_id: @roots_type.root_id
          })
        }
      else
        format.html { render action: "edit", template: "new_edit" }
      end
    end
  end

  def destroy
    @roots_type.destroy

    respond_to do |format|
      format.html { redirect_to properties_roots_types_url(
        properties_roots_types: {
          root_type: @roots_type.root_type,
          root_id: @roots_type.root_id
        })
      }
      format.json { render json: @roots_type }
    end
  end

  private

  def check_row_num
    hash = { root_type: params[:root_type], root_id: params[:root_id], type_id: params[:type_id] }
    row_num_record = Admin::RowNum::Fix.new(::Properties::RootsTypes, nil, hash)
    if !params[:cancel_check_row_num] && row_num_record.need_check?
      redirect_to template_system.admin_edit_fix_row_num_url(::Properties::RootsTypes, model_module: nil, opt: hash)
    end
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@types_value || ::Properties::RootsTypes, namespace: 'properties', model_engine: 'main_app')
    @roots_types_hash = { root_type: params.dig('properties_roots_types', 'root_type'),
                          root_id: params.dig('properties_roots_types', 'root_id') }
    @admin_panel.from(controller_name, action_name)
  end
end

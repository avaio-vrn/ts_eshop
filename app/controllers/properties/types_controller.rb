class Properties::TypesController < GenericController
  load_and_authorize_resource
  include OnlySupersController

  def index
    if current_user&.admin_less? && admin_view?
      @list_pages = Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = Properties::Type.ordering.page(params[:page])
      end
      respond_to do |format|
        format.html { render 'admin_index' }
        format.json { render json: @list_pages }
      end
    else
      redirect_to root_path
    end
  end

  private

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@type || Properties::Type)
    @admin_panel.model_engine = 'main_app'
    @admin_panel.default_namespace = 'properties'
    @admin_panel.from(controller_name, action_name)
  end
end

class BannersController < GenericController
  load_and_authorize_resource

  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  include OnlySupersController

  def index
    if current_user&.admin_less? && admin_view?
      @list_pages = Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = @banners.ordering.page(params[:page])
      end
      render 'admin_index'
    else
      raise ExceptionsErrors::AuthenticationError.new
    end
  end

  def show
    render 'show', locals: { without_remove: true }
  end

  private

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@banner || ::Banner, { namespace: '' })
    @admin_panel.from(controller_name, action_name)
  end

end

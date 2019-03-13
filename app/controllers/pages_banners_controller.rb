class PagesBannersController < GenericController
  authorize_resource

  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  def index
    if current_user && current_user.admin_less? && admin_view?
      @pages_banners = PagesBanner.where(root_type: params[:root_type], root_id: params[:root_id])
      @list_pages = Admin::ListPages.new do |l|
        l.controller_name = controller_name
        l.action_name = action_name
        l.list = @pages_banners.page(params[:page])
      end

      render 'admin_index'
    else
      raise ExceptionsErrors::AuthenticationError.new
    end
  end

  def new
    @pages_banner = PagesBanner.new(params.slice(:root_type, :root_id).merge(new_banner_dates))
    render 'new_edit'
  end

  def create
    @pages_banner = PagesBanner.new(params[:pages_banner])

    respond_to do |format|
      if @pages_banner.save
        format.js { render 'create' }
        format.html { redirect_to pages_banner_url(@pages_banner), notice: view_context.h_flash_msg(:create) }
      else
        format.html { render action: :edit, template: '/application/new_edit' }
      end
    end
  end

  def edit
    super
  end

  def update
    super
  end

  def destroy
    pages_banner = PagesBanner.find(params[:id])
    pages_banner.destroy

    respond_to do |format|
      format.html { redirect_to pages_banner_url(root_type: pages_banner.root_type, root_id: pages_banner.root_id) }
      format.json { render json: pages_banner.to_json }
    end
  end


  private

  def new_banner_dates
    { datetime_start: Time.now.in_time_zone, datetime_stop: Time.now.in_time_zone + 1.day }
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@pages_banner || PagesBanner, { namespace: '' })
    @admin_panel.from(controller_name, action_name)
    @return_page = params[:root_type].constantize.find(params[:root_id]) if params[:root_type]
    @pages_banner_args = { action: :new, root_type: params[:root_type], root_id: params[:root_id] }
  end
end

# frozen_string_literal: false

class Admin::Goods::GoodsErrorsController < ApplicationController
  def show
    authorize! :show, Admin::Goods::GoodsErrors

    @admin_panel = ::Admin::Panel::Base.new
    @admin_panel.from(controller_name, action_name)
    @admin_panel.routes = [:edit, :show]

    @current_page_list = Kaminari.paginate_array(Admin::Goods::GoodsErrors.new(params[:id]).items).page(params[:page])
    @list_pages = Admin::ListPages.new do |l|
      l.controller_name = controller_name
      l.action_name = action_name
      l.list = @current_page_list
    end

    render 'admin_index'
  end
end

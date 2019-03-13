# -*- encoding : utf-8 -*-
class ApplicationController < TemplateSystemController
  layout :default_or_system?

  before_filter :main_instances, unless: proc{ |c| c.request.xhr? }
  before_filter :current_basket, unless: proc{ |c| c.request.xhr? }

  def main_instances
    @biz_info = BizInfo.new
    @main_instances = MainInstances.new
  end

  private

  def current_basket
    return @current_basket unless @current_basket.nil?
    @current_basket = Basket.find(session[:basket_id])
  rescue ActiveRecord::RecordNotFound
    @current_basket = Basket.new(user_id: current_user&.id, contacts: current_user&.email)
    @current_basket
  end

  def default_or_system?
    request.xhr? ? false : current_user&.admin_less? ? admin_layout : user_layouts
  end

  def admin_layout
    ['edit', 'update'].include?(action_name) ? 'admin_edit_record' : "admin_#{user_layouts}"
  end

  def user_layouts
    case controller_name
    when 'baskets'
      'basket'
    when 'pages'
      'page'
    when 'content'
      'content'
    else
      'application'
    end
  end
end

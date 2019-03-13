# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :manage, :all
      can :del, :all
    elsif user.admin_less?
      can :read, :all
      can :del, :all
      can :update, :all
      cannot :destroy, :all
    else
      can :read, :all
      can [:create, :update, :destroy], BasketItem
      can [:order, :send_order], Page
      can [:order_view, :change_view, :set_per_page, :popular_goods], Section
      can [:registration, :info, :thanks, :send_order, :list], Basket

		  cannot :index, Page
      cannot :index, :tovar_list
      cannot :show, [Admin::Goods::HealthCheck, Admin::Goods::GoodsErrors]
      cannot :index, [Admin::TemplateSystem::PersistentData]
      cannot :read, [User, TemplateSystem::Template, TemplateSystem::TemplateType, Seo::MetaTag,
                     TemplateSystem::TemplateContent, TemplateSystem::TemplateTableContent]
    end
  end
end

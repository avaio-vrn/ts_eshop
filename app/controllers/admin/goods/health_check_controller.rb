# frozen_string_literal: false

class Admin::Goods::HealthCheckController < ApplicationController
  def show
    authorize! :show, Admin::Goods::HealthCheck

    @admin_panel = ::Admin::Panel::Base.new
    @admin_panel.from(controller_name, action_name)

    render 'show', locals: { health_check: ::Admin::Goods::HealthCheck.new }
  end
end

# frozen_string_literal: false

class Admin::Goods::TovarListController < ApplicationController
  authorize_resource class: false

  before_filter :find_record, only: :update
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  def update
    respond_to do |format|
      if @tovar_model.update_attributes(price: params[:price])
        format.js { render inline: 'showFlashMessage(\'<span class="flash-icon flash--apply"></span><div class="notice">Запись обновлена</div>\')', status: 200, layout: nil }
      else
        format.js { render nothing: true, status: 500, layout: nil }
      end
    end
  end

  private

  def find_record
    @tovar_model = ::TovarModel.find(params[:id])
    raise ActiveRecord::RecordNotFound if @tovar_model.blank?
  end

  def set_actions
    @admin_panel = ::Admin::Panel::Base.new(:tovar_list)
    @admin_panel.from(controller_name, action_name)
  end
end

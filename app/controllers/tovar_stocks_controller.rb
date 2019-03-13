class TovarStocksController < ApplicationController
  authorize_resource class: false
  before_filter :set_actions, if: proc { current_user&.admin_less? }

  def new
    @tovar_stocks = @admin_panel.full_obj
    @tovar_stocks.price_current = @admin_panel.obj_for_t.min_price

    render 'new_edit'
  end

  def create
    tovar = Tovar.find(params['tovar_stocks']['tovar_id'])

    ActiveRecord::Base.transaction do
      tovar.tovar_models.each do |tm|
        TovarStocks.create!(params['tovar_stocks'].merge(tovar_model_id: tm.id))
      end
    end

    redirect_to tovar_url(tovar)
  end

  private

  def set_actions
    @admin_panel = Admin::Panel::Base.new(TovarStocks.new(tovar_id: params[:tovar_id]))
    @admin_panel.obj_for_t = Tovar.find(params[:tovar_id])
    @admin_panel.default_namespace = ''
    @admin_panel.from(controller_name, action_name)
  end
end

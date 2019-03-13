class ImportPricelistController < ApplicationController
  skip_load_resource
  authorize_resource
  before_filter :set_actions, if: proc { current_user&.admin_less? }

  def new
  end

  def create
    @import_pricelist = ImportPricelist.new(params[:file].tempfile).save

    if @errors.blank?
      render 'create'
    else
      render action: :new
    end
  end

  private

  def set_actions
    @admin_panel = Admin::Panel::Base.new(:import_pricelist)
    @admin_panel.from(controller_name, action_name)
  end
end

# frozen_string_literal: false
# == Schema Information
#
# Table name: property_types
#
#  id           :integer          not null, primary key
#  content_name :string(255)
#  input_type   :string(20)
#  del          :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class PropertyTypesController < GenericController
  load_and_authorize_resource
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  include OnlySupersController

  def index
    if current_user&.admin_less? && admin_view?
      if request.format.symbol == :html
        @list_pages = Admin::ListPages.new do |l|
          l.controller_name = controller_name
          l.action_name = action_name
          l.list = @property_types.ordering.page(params[:page])
        end
      else
        @list_pages = if params[:q]
                        PropertyType.not_deleted.where(PropertyType.arel_table[:content_name].matches("%#{params[:q]}%")).ordering
                      else
                        @property_types
                      end
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
    @admin_panel = Admin::Panel::Base.new(@property_type || PropertyType, namespace: '')
    @admin_panel.from(controller_name, action_name)
  end
end

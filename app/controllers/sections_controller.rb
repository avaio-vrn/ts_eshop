# == Schema Information
#
# Table name: sections
#
#  id              :integer          not null, primary key
#  content_name    :string(255)
#  content_header  :string(255)
#  row_num         :integer
#  del             :boolean
#  id_str          :string(70)
#  parent_id       :integer
#  first_parent_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SectionsController < GenericController
  authorize_resource

  before_filter :find_record, only: :show
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  def index
    @sections = Section.where(parent_id: nil)
  end

  def show
    @child_sections = @section.child_sections.not_deleted.ordering

    @tovar_models = ::SectionTovarModelsOrderAndPage.new(@section, session, params[:page]).tovar_models.available
    @title = @section.content_header

    unless @tovar_models.blank?
     @filter = Filters::Section.new(section_id: @section.id)
    end

    change_view if params[:view]

    respond_to do |format|
      format.html {
        render show_template_get
      }
      format.js { render js: "window.location.href = '#{params[:url]}'" }
    end
  end

  def set_per_page
    if ['12', '24', '60', '120'].include? params[:per_page]
      session[:kaminari_per_page] = params[:per_page].to_i
    else
      session.delete(:kaminari_per_page)
    end
    respond_to do |format|
      format.html { redirect_to section_path(@section) }
      format.js { render js: "window.location.href = '#{params[:url]}'" }
    end
  end

  # def order_view
  #   sym = params[:type].to_sym
  #   session[:section_order] = {} if session[:section_order].nil? || session[:section_order][sym].nil?
  #   session[:section_order][params[:type].to_sym] =
  #     if session[:section_order].nil?
  #       true
  #     else
  #       session[:section_order][sym].nil? ? true : !session[:section_order][sym]
  #     end
  #   redirect_to section_path(@section)
  # end

  private

  def find_record
    @section = ::Section.where(id_str: params[:id]).first
    raise ActiveRecord::RecordNotFound if @section.blank?
  end

  def change_view
    if params[:view] == 'cards'.freeze
      session.delete(:section_tovar_index)
      false
    elsif params[:view] || session[:section_tovar_index] == :list
      session[:section_tovar_index] = :list
      true
    else
      false
    end
  end

  def show_template_get
    if @tovar_models.blank?
      'show'
    elsif change_view
      'show_with_tovars'
    else
      'show_with_tovars_cards'
    end
  end

  def set_actions
    @admin_panel = Admin::Panel::Base.new(@section || ::Section)
    @admin_panel.from(controller_name, action_name)
    @parent_id = params[:parent_id]
    @has_child_sections = !@section&.child_sections.blank? || (@section&.child_sections.blank? && @section&.tovars.blank?)
    @has_tovars = !@section&.tovars.blank? || (@section&.child_sections.blank? && @section&.tovars.blank?)
  end
end

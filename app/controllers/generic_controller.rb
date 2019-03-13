class GenericController < ApplicationController
  before_filter :set_actions, if: proc { request.format.symbol == :html && current_user&.admin_less? }

  protected

  def index
    instance_variable_set("@#{controller_name.singularize}s", klass.scoped)
    #   if current_user && current_user.admin_less? && admin_view?
    #     @list = Section.ordering
    #     Admin::AdminController.check_row_num! :section
    #     render 'admin_index'
    #   else
    #     redirect_to root_path
    #   end
    respond_to do |format|
      format.html {render :index }
      format.json {render json:  instance_variable_get("@#{controller_name.singularize}s")}
    end
  end

  def show
    var = instance_variable_get("@#{controller_name.singularize}") || find_one_record
    @title = var.content_header if var.respond_to? :content_header
    respond_to do |format|
      format.html {render :show }
      format.json {render json:  var }
    end
  end

  def new
    instance_variable_set("@#{controller_name.singularize}", klass.new)
    respond_to do |format|
      format.html { render action: :new, template: '/application/new_edit' }
    end
  end

  def edit
    instance_variable = instance_variable_get("@#{controller_name.singularize}") || find_one_record
    respond_to do |format|
      format.html { render action: :edit, template: '/application/new_edit' }
    end
  end

  def create
    instance_variable = instance_variable_set("@#{controller_name.singularize}", klass.new(params[klass.model_name.param_key]))

    respond_to do |format|
      if instance_variable.save!
        begin
          url = polymorphic_url(instance_variable)
          Rails.application.routes.recognize_path(url)
        rescue
          url = polymorphic_url(@admin_panel.full_obj)
        end

        format.html { redirect_to url, notice: view_context.h_flash_msg(:create) }
      else
        format.html { render action: :new, template: "/application/new_edit" }
      end
    end
  end

  def update
    instance_variable = instance_variable_get("@#{controller_name.singularize}") || find_one_record

    respond_to do |format|
      if instance_variable.update_attributes(params[klass.model_name.param_key])
        begin
          url = polymorphic_url(instance_variable)
          Rails.application.routes.recognize_path(url)
        rescue
          url = polymorphic_url(@admin_panel.full_obj)
        end

        format.html { redirect_to url, notice: view_context.h_flash_msg(:update) }
      else
        format.html { render action: :edit, template: "/application/new_edit" }
      end
    end
  end

  def destroy
    instance_variable = instance_variable_get("@#{controller_name.singularize}") || find_one_record
    instance_variable.destroy
    respond_to do |format|
      format.html { redirect_to polymorphic_url(@admin_panel.full_obj) }
      format.json { render json: instance_variable }
    end
  end

  private

  def klass
    Object.const_get(self.class.to_s.gsub('Controller', '').singularize.classify)
  end

  def find_one_record
    instance_variable_set("@#{controller_name.singularize}",
                          klass.find(params[:id]) || raise(ActiveRecord::RecordNotFound))
  end
end

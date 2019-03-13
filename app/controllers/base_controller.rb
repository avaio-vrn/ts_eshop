# frozen_string_literal: false

class BaseController < ApplicationController
  def home
    @welcome_goods = Base.tovars_for_welcome_page.page(params[:page]).per(12)

    respond_to do |format|
      format.html do
        @title ||= 'Официальный сайт'
        @page = Page.where(id_str: :home_index_page).first

        admin_panel if current_user&.admin_less?

        render action: :welcome, layout: current_user&.admin_less? ? 'admin_application_welcome' : 'application_welcome'
      end

      format.js { render 'welcome', layout: nil }
    end
  end

  def search
    admin_panel if current_user&.admin_less?
    @base = :search
    @title = 'Результаты поиска'
    fill_finding_model = [[Section, '']] <<
                         [TemplateSystem::TemplateContent, ''] <<
                         [TemplateSystem::TemplateTableContent, '']
    @searches = []
    unless params[:search_f].blank?
      @finding_tovars = { name: 'Товары', full: Tovar.search(Riddle::Query.escape(params[:search_f])) }

      fill_finding_model.each do |model|
        result = model[0].search(Riddle::Query.escape(params[:search_f]))
        @searches << { name: model[1], full: result } unless result.blank?
      end
    end

    @searches_blank = @searches.all?(&:blank?)

    render '/search/index'
  end

  def novinki
    @section = Section.new(content_header: 'Новинки')
    @welcome_goods = Base.novinki.page(params[:page]).per(9)
    if @welcome_goods.blank?
      @welcome_goods = Kaminari.paginate_array(Tovar.order('created_at DESC').limit(27)).page(params[:page]).per(9)
    end
    @title = 'Новинки ассортимента'
    respond_to do |format|
      format.html { render 'show_with_tovars_cards' }
      format.js { render 'welcome', layout: nil }
    end
  end

  def aktsii
    @stock_goods = TovarStocks.order(updated_at: :desc).map(&:tovar)
    @page = Page.where(id_str: 'aktsii').first

    admin_panel if current_user&.admin_less?
  end

  def question_form
    respond_to do |format|
      format.html { render nothing: true, status: 204 }
      format.js { render 'application/question_message/question_message' }
    end
  end

  def send_question_form
    customer_mail = SiteMailerManager.send_question(params, recepient: true)
    customer_mail&.deliver
    config_get('biz_info', 'email_for_form').split(',').each do |to|
      SiteMailerManager.send_question(params, to: to).deliver
    end
    respond_to do |format|
      format.js { render 'application/question_message/send_question_message' }
    end
  end

  private

  def admin_panel
    @admin_panel = Admin::Panel::Base.new(@page.nil? ? :search : @page)
    @admin_panel.from(controller_name, action_name)
  end
end

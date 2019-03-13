# frozen_string_literal: false

class SearchController < ApplicationController
  def index
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

  private

  def admin_panel
    @admin_panel = Admin::Panel::Base.new(@page.nil? ? :search : @page)
    @admin_panel.from(controller_name, action_name)
  end
end

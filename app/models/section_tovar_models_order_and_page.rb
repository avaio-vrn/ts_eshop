# frozen_string_literal: false

class SectionTovarModelsOrderAndPage
  def initialize(section, session, page=nil)
    tovar_models = section.tovar_models.available.group('tovar_models.tovar_id')
    tovar_models =
      if session[:section_order].nil?
        tovar_models.order('tovars.row_num')
      elsif session[:section_order].key? :alph
        tovar_models.order('tovars.content_name' << (session[:section_order][:alph] ? '' : ' DESC'))
      elsif session[:section_order].key? :date
        tovar_models.order('tovars.created_at' << (session[:section_order][:date] ? '' : ' DESC'))
      elsif session[:section_order].key? :price
        tovar_models.order('tovars.price' << (session[:section_order][:price] ? '' : ' DESC'))
      else
        tovar_models.order('tovars.created_at DESC')
      end
    @tovar_models = tovar_models.page(page).per(session[:kaminari_per_page] || 12)
  end

  def tovar_models
    @tovar_models
  end
end

# frozen_string_literal: false

class Base
  def self.tovars_for_welcome_page
    section_id = Section.main_sections.first.id
    Tovar.includes(:tovar_models).where('tovars.del = false AND tovars.section_id = ?', section_id)
      .where('tovar_models.del = false AND tovar_models.discontinued = false AND tovar_models.in_stock = true')
      .order('tovar_models.created_at DESC').select('DISTINCT tovars.*')
  end

  def self.novinki
    Tovar.includes(:tovar_models).where('tovars.del = false AND tovars.created_at > ?', DateTime.now.in_time_zone - 1.week)
      .where('tovar_models.del = false AND tovar_models.discontinued = false AND tovar_models.in_stock = true')
      .order('tovar_models.created_at DESC').select('DISTINCT tovars.*')
  end
end

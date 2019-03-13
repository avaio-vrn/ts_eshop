# -*- encoding : utf-8 -*-
# frozen_string_literal: false

module ApplicationHelper
  def body_state
    if @current_basket.nil? || @current_basket.empty?
      panel_state
    else
      ['baractive '.freeze, panel_state].join
    end
  end

  def h_view_button_active(type)
    case type
    when :cards then session['section_tovar_index'].blank? ? ' view-button--active' : ''
    when :list then !session['section_tovar_index'].blank? ? ' view-button--active' : ''
    end
  end

  private

  def without_kop?(price)
    price.to_f == price.to_i
  end
end

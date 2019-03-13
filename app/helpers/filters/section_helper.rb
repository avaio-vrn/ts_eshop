# frozen_string_literal: false

module Filters
  module SectionHelper
    def h_filter
      return nil if @filter.property_values.blank?
      content_tag :div, class: 'js__filter-ctn filter-container m-s--no', data: { 'sc-id' => @section.id } do
        content_tag(:p, 'Фильтр', class: 'filter-title') << sidebar_form_get
      end
    end

    # def form_get
    #   form = ''.html_safe
    #   @filter.property_values.map do |prop|
    #     prop_name = PropertyType.find(prop[0]).content_name
    #     list = content_tag(:div, prop_name, data: { 'pt-id' => prop[0] }, class: 'filter-name')
    #     list_ch = ''.html_safe
    #     prop[1].map(&:value).compact.uniq.sort.map do |val|
    #       sec = SecureRandom.hex(6)
    #       list_ch << content_tag(:span, check_box_tag(sec, val) << label_tag(sec, val, class: 'content-link content-link--onpage'), class: 'checkbox-label')
    #     end
    #     list << content_tag(:div, content_tag(:p, prop_name) << content_tag(:i, '', class: 'fa fa-times js__close') << list_ch, class: 'filter-ch-container')
    #     form << content_tag(:div, list, class: 'filter-checkboxs')
    #   end
    #   form
    # end

    def sidebar_form_get
      form = ''.html_safe
      @filter.property_values.map do |prop|
        prop_record = PropertyType.find(prop[0])
        list = content_tag(:p, prop_record.content_name, data: { 'pt-id' => prop[0] }, class: 'goods-prop-title')
        list_ch = ''.html_safe
        if prop_record.value_type == 1
          minmax = prop[1].map(&:value).map { |e| e.tr(',', '.') }.map(&:to_f).minmax
          list_ch << content_tag(:span, '', class: 'filter-slider', data: { min: minmax[0], max: minmax[1] })
          # list_ch << number_field_tag("left_value-#{prop[0]}", minmax[0], class: 'input', in: minmax[0]..minmax[1])
          # list_ch << number_field_tag("right_value-#{prop[0]}", minmax[1], class: 'input', in: minmax[0]..minmax[1])
        else
          prop[1].map(&:value).compact.uniq.sort.map do |val|
            list_ch << content_tag(:span, val, class: 'goods-prop-value')
          end
        end
        form << content_tag(:div, list << content_tag(:div, list_ch, class: 'goods-prop-values'), class: 'filter-checkboxs clfl')
      end
      form
    end
  end
end

# frozen_string_literal: false

class Filters::SectionsController < ApplicationController
  def show
    @filter = Filters::Section.new(section_id: params[:section_id])
    respond_to do |format|
      format.html { render nothing: true, status: 204 }
      format.js { render action: :show, layout: false }
    end
  end

  def update
    @goods = if params[:values].blank? && params['slidersValues'].blank?
      @with_page = true
      section = ::Section.where(id: params[:section_id]).first
      section.blank? ? [] : ::SectionTovarModelsOrderAndPage.new(section, session, params[:page]).tovar_models.available.map(&:tovar)
    else
      if params[:values].blank?
        similar_goods = ::TovarModel
        .not_deleted.available
        .joins(:tovar)
        .where(tovars: ::Tovar.available_hash(params[:section_id]))
      else
        filter_prop_value = params[:values].group_by { |_k, v| v['pt'] }
        filter_prop_value.map do |k, v|
          v.map! { |v| v = v[1]['val'] }
        end

        filter_prop_ids = filter_prop_value.keys

        similar_goods = ::TovarModel
        .not_deleted.available
        .joins(:tovar_models_properties, :tovar)
        .where(tovars: Tovar.available_hash(params[:section_id]))
        .where(tovar_models_properties: { property_type_id: filter_prop_ids[0], value: filter_prop_value[filter_prop_ids[0]] })

        filter_prop_ids.each_with_index do |prop, i|
          next if i.zero?

          similar_goods &= ::TovarModel
          .not_deleted.available
          .joins(:tovar_models_properties, :tovar)
          .where(tovars: Tovar.available_hash(params[:section_id]))
          .where(tovar_models_properties: { property_type_id: prop, value: filter_prop_value[prop] })
        end
      end

      params['slidersValues']&.each do |_k, v|
        min = v['val'][0].to_f
        max = v['val'][1].to_f
        ids = []
        similar_goods.each do |record|
          record.tovar_models_properties.where(property_type_id: v[:pt]).each do |tmp_records|
            ids << record.id if (min..max).cover? tmp_records.value.tr(',', '.').to_f
          end
        end

        similar_goods = if ids.blank?
          []
        else
          similar_goods.select { |e| ids.include? e.id }
        end
      end

      similar_goods.map(&:tovar).uniq
    end

    @filter_string = if params[:values].blank?
      'Фильтр не выбран'
    else
      params[:values].map { |_k, v| "#{v[:type_name]} = #{v[:val]}" }.join(' и ')
    end

    @partial = if session[:section_tovar_index] == :list
      'tovar'
    else
      'tovar_short'
    end

    respond_to do |format|
      format.html { render nothing: true, layout: nil, status: 204 }
      format.js {
        render action: :update, layout: nil
      }
    end
  end
end

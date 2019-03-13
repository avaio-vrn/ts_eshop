# frozen_string_literal: false

class Goods::Similar
  def initialize(tovar, args = {})
    @tovar = tovar || ::Tovar.find(args[:tovar_id])
  end

  def get(limit=nil)
    return nil if @tovar.tovar_model.blank?
    filter_prop_ids = @tovar.tovars_properties.where(similar_prop: true).map(&:property_type_id).sort
    filter_prop_value = @tovar.tovar_model.tovar_models_properties.where(property_type_id: filter_prop_ids).order(:property_type_id).map(&:value)

    similar_goods = tovar_models_query(filter_prop_ids.unshift, filter_prop_value.unshift)

    filter_prop_ids.each_with_index do |prop, i|
      similar_goods &= tovar_models_query prop, filter_prop_value[i]
    end

    similar_goods = similar_goods[0..limit-1] if limit
    similar_goods.map(&:tovar).uniq
  end

  private

  def tovar_models_query(prop_id, value)
    ::TovarModel.joins(:tovar_models_properties, :tovar)
      .where(tovars: Tovar.available_hash(@tovar.section_id))
      .where(::TovarModel.arel_table[:tovar_id].not_eq(@tovar.id))
      .where(tovar_models_properties: { property_type_id: prop_id, value: value })
      .not_deleted.ordering
  end
end

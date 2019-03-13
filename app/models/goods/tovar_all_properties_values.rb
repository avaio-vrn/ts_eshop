# frozen_string_literal: false

class Goods::TovarAllPropertiesValues
  def initialize(tovar = nil, args = {})
    @tovar = tovar
    property_types_arrays_set
    self
  end

  def model_property_types
    if @tovar.show_card
    @tovar.tovars_properties.joins(:property_type).select('property_types.id, property_types.content_name, property_types.del')
      .where(in_card_prop: true)
      .order('tovars_properties.row_num, tovars_properties.created_at')
    else
    @tovar.tovars_properties.joins(:property_type).select('property_types.id, property_types.content_name, property_types.del')
      .order('tovars_properties.row_num, tovars_properties.created_at')
    end
  end

  def just_property_values
    @property_types_arrays[:just_property_values]
  end

  def tovar_models_properties
    @property_types_arrays[:tovar_models_properties]
  end

  def property_values
    @property_values
  end

  private

  def property_types_arrays_set
    @property_types_arrays = if @tovar.discontinued
                               { tovar_models_properties: [] }
                             else
                               all_or_in_card
                             end

    @property_values = {}
    just_property_values = {}
    @property_types_arrays.dig(:tovar_models_properties).map do |t|
      next if t.value.blank?
      tovar_model = t.tovar_model
      @property_values[t.tovar_model_id.to_s.strip] ||= {}
      @property_values[t.tovar_model_id.to_s.strip].merge!(id: tovar_model.id,
                                                           'vendor_code' => tovar_model.vendor_code,
                                                           t.property_type_id.to_s.strip => t.value,
                                                           price:  tovar_model.price_in_rub,
                                                           currency_sym: tovar_model.currency_sym,
                                                           css_class: css_class(tovar_model))
      just_property_values[t.property_type_id] ||= {}
      just_property_values[t.property_type_id].merge!(t.value.strip => (just_property_values.dig(t.property_type_id, t.value.to_s.strip) || []) << t.tovar_model_id)
    end

    @property_types_arrays[:just_property_values] = just_property_values
  end

  def css_class(tovar_model)
    if tovar_model.popular_model
      ' model-popular'
    elsif tovar_model.use_in_new
      ' model-new'
    end
  end

  def all_or_in_card
    if @tovar.show_card
      { tovar_models_properties: @tovar.tovar_models_properties.includes(tovar_model: :tovar_stocks).
        where(property_type_id: @tovar.tovars_properties.where(in_card_prop: true).pluck(:property_type_id)).
        where('tovar_models.del = false AND tovar_models.discontinued = false AND tovar_models.in_stock = true')
      }
    else
      { tovar_models_properties: @tovar.tovar_models_properties.includes(tovar_model: :tovar_stocks)
        .where('tovar_models.del = false AND tovar_models.discontinued = false AND tovar_models.in_stock = true')
      }
    end
  end
end

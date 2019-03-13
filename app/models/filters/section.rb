class Filters::Section
  attr_reader :property_values

  def initialize(section_id: )
    @section_id = section_id
    pt_id = goods_with_filter_prop_true

    #TODO check wtf?
    # pt_id = goods_with_filter_without_check_prop if pt_id.blank?

    return nil if pt_id.blank?
    @property_values = TovarModelsProperty.where(tovar_model_id: goods_variants_arr, property_type_id: pt_id)
      .order(:property_type_id, :value)
      .joins(:property_type)
      .select([:property_type_id, :value]).group_by(&:property_type_id)
  end

  private

  def goods_variants_arr
    TovarModel.joins(:tovar).where(TovarModel.available_hash.merge(tovars: Tovar.available_hash(@section_id))).pluck(:id)
  end

  def goods_with_filter_prop_true
    TovarsProperty.where(tovar_id: Tovar.where(Tovar.available_hash(@section_id)).pluck(:id), filter_prop: true)
      .pluck(:property_type_id)
  end

  def goods_with_filter_without_check_prop
    TovarsProperty.where(tovar_id: Tovar.where(Tovar.available_hash(@section_id)).pluck(:id)).pluck(:property_type_id)
  end
end

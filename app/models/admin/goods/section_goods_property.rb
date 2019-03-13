class Admin::Goods::SectionGoodsProperty < ActiveRecord::Base
  has_many :tovars_properties

  accepts_nested_attributes_for :tovars_properties, allow_destroy: true

  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
                                                            sql_type.to_s, null)
  end

  def save(validate = true)
    validate ? (save_record if valid?) : save_record
  end

  def section_id=(value)
    @section_id = value
  end

  def section_id
    @section_id
  end

  def params=(value)
    @params = value
  end

  def persisted?
    false
  end

  private

  def save_record
    fix_tovars_properties_attributes
    section = Section.find(@params["admin_goods_section_goods_property"]["section_id"])
    section.tovars.each do |tovar|
      exists_records = tovar.tovars_properties.pluck(:id)
      @params["admin_goods_section_goods_property"]["tovars_properties_attributes"].each_with_index do |(_k, prm), index|
        tp = tovar.tovars_properties.where(property_type_id: prm['property_type_id']).first
        if tp
          tp.row_num = index
          tp.force_save = true
          tp.filter_prop = prm['filter_prop']
          tp.similar_prop = prm['similar_prop']
          tp.save!
          exists_records -= [tp.id]
        else
          TovarsProperty.create(prm.merge(tovar_id: tovar.id, row_num: index))
        end
      end

      exists_records.each do |id|
        TovarsProperty.find(id).destroy
      end
    end
  end

  def fix_tovars_properties_attributes
    @params["admin_goods_section_goods_property"]["tovars_properties_attributes"].each do |_k, prm|
      prm.delete('_destroy')
      prop = prm['property_type_id'].split(',')
      if prop.size >= 1 && prop[0].to_s.length != prop[0].to_i.to_s.length
        prop[1] = PropertyType.create(content_name: prm[:property_type_id].gsub(/\A\d*,\s*/, '').strip).id
      end
      prm['property_type_id'] = prop[1].nil? ? prop[0].to_s : prop[1].to_s
    end
  end
end

# == Schema Information
#
# Table name: tovars_properties
#
#  id               :integer          not null, primary key
#  row_num          :integer
#  tovar_id         :integer
#  property_type_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  filter_prop      :boolean
#  similar_prop     :boolean
#  del              :boolean          default(FALSE)
#  value_type       :integer
#

class TovarsProperty < TemplateSystem::Record::DelRowNum

  ROW_NUM_FIELDS = [:tovar_id].freeze

  after_create  :create_tovar_models_properties
  after_destroy :destroy_tovar_models_properties
  set_callback :update, :after, :update_tovar_models_properties

  belongs_to :tovar
  belongs_to :property_type

  attr_accessible :property_type_id, :tovar_id, :row_num, :filter_prop, :similar_prop, :in_card_prop

  validate :tovar_id, :property_type_id, presence: true

  scope :ordering, -> { order(:row_num) }

  def to_s
    property_type.to_s
  end

  private

  def update_tovar_models_properties
    if self.property_type_id_changed?
      models = tovar_models.pluck(:id)
      a = TovarModelsProperty.where(property_type_id: self.property_type_id_was, tovar_model_id: models)
                             .update_all(property_type_id: self.property_type_id)
    end
  end

  def create_tovar_models_properties
    h = tovar_models.inject([]) do |m,e|
      m.push({
        property_type_id: self.property_type_id,
        tovar_model_id: e.id
      })
    end
    TovarModelsProperty.create!(h)
  end

  def destroy_tovar_models_properties
    models = tovar_models.pluck(:id)
    TovarModelsProperty.where(property_type_id: self.property_type_id, tovar_model_id: models).map(&:destroy)
  end

  def tovar_models
    TovarModel.where(tovar_id: self.tovar_id).select([:id, :del, :content_name])
  end
end

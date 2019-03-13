# == Schema Information
#
# Table name: tovar_models_properties
#
#  id               :integer          not null, primary key
#  tovar_model_id   :integer
#  property_type_id :integer
#  value            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TovarModelsProperty < ActiveRecord::Base
  belongs_to :tovar_model
  belongs_to :property_type
  has_one :tovar, through: :tovar_model
  has_many :tovars_properties, through: :tovar

  attr_accessible :property_type_id, :tovar_model_id, :value

  def to_s
    value
  end
end

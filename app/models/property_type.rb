# frozen_string_literal: false

# == Schema Information
#
# Table name: property_types
#
#  id           :integer          not null, primary key
#  content_name :string(255)
#  input_type   :string(20)
#  del          :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  value_type   :integer
#

class PropertyType < TemplateSystem::Record::Del
  has_many :tovars_properties
  has_many :tovars, through: :tovars_properties
  has_many :tovar_models_properties
  # has_many :tovars, through: :tovar_models_properties

  scope :ordering, -> { order(:content_name) }

  attr_accessible :content_name, :value_type

  validates :content_name, presence: true

  def self.value_type_collection
    [[0, 'Строковое'], [1, 'Числовое'], [2, 'Логическое(да/нет)']]
  end

  def to_s
    content_name
  end

  def content_header
    content_name
  end
end

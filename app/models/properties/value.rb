class Properties::Value < ActiveRecord::Base
  belongs_to :root, polymorphic: true
  has_many :types_values
  has_many :types, class_name: '::Properties::Type', through: :types_values

  scope :ordering, -> { order(:content_name) }

  attr_accessible :content_name

  def to_s
    content_name
  end
end

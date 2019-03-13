# == Schema Information
#
# Table name: banners
#
#  id           :integer          not null, primary key
#  content_name :string(255)
#  content_text :text
#  href         :string(255)
#  del          :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Banner < TemplateSystem::Record::Del
  has_many :pages_banners
  has_one :image, class_name: 'Files::Image', as: :root

  attr_accessible :content_name, :href, :content_text, :image_attributes

  accepts_nested_attributes_for :image, allow_destroy: true

  scope :ordering, -> { order(:content_name) }

  def to_s
    content_name
  end

  def image
    super || build_image
  end
end

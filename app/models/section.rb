# == Schema Information
#
# Table name: sections
#
#  id              :integer          not null, primary key
#  content_name    :string(255)
#  content_header  :string(255)
#  row_num         :integer
#  del             :boolean
#  id_str          :string(70)
#  parent_id       :integer
#  first_parent_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  in_menu         :boolean
#

class Section < TemplateSystem::Record::Base
  extend Concerns::SimpleSearch
  include Concerns::IncludeBanner

  ROW_NUM_FIELDS = [:parent_id]

  after_destroy :fix_row_num

  belongs_to :parent, class_name: Section
  has_many :child_sections, class_name: Section, foreign_key: :parent_id, dependent: :destroy
  has_many :tovars, dependent: :destroy
  has_many :tovar_models, through: :tovars

  attr_accessible :content_header, :content_name, :parent_id, :first_parent_id, :in_menu,
    :child_sections_attributes

  accepts_nested_attributes_for :child_sections, allow_destroy: true

  scope :main_sections, -> { where(parent_id: nil).not_deleted.ordering }
  scope :inside_sections, ->(parent_id) { where(parent_id: parent_id).not_deleted.ordering }

  validates_presence_of :content_name

  def invert_obj
    ['admin', self]
  end

  def to_s
    content_name
  end

  def content_header
    super || content_name
  end

  def deep_content_name(name='')
    name.concat(content_name)
    parent.deep_content_name(name.concat(' / ')) unless parent.nil?
    name
  end

  def main_image(style=:thumb)
    image.blank? ? main_image_section_or_tovar(style) : image.url(style)
  end

  def main_image_section_or_tovar(style=:thumb, level_section=self)
    if image.blank? && level_section.tovars.blank? && !level_section.child_sections.blank?
      main_image_section_or_tovar(style, level_section.child_sections.first)
    else
      if image.blank?
        level_section.tovars.blank? ? '/assets/no_img.png' : level_section.tovars.first.main_image(style)
      else
        image.url(style)
      end
    end
  end

  def novinki(limit=nil)
    tovars = Tovar.includes(:tovar_models).where(Tovar.available_hash(self.id).merge(tovar_models: TovarModel.available_hash))
      .order('tovar_models.created_at DESC').select('DISTINCT tovars.*')
    limit.nil? ? tovars : tovars.limit(limit)
  end

  def count_tovars
    TovarModel.includes(:tovar).where('tovar_models.del = false AND tovars.del = false AND tovars.section_id = ?', self.id).count(:tovar_id)
  end

  private

  def fix_row_num
    Admin::RowNum::Fix.new(:section, nil, { parent_id: parent_id }, { destroyed: self.row_num }).after_destroy!
  end
end

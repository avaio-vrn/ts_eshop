# == Schema Information
#
# Table name: pages_banners
#
#  id             :integer          not null, primary key
#  root_type      :string(255)
#  root_id        :integer
#  banner_id      :integer
#  datetime_start :datetime
#  datetime_stop  :datetime
#  del            :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PagesBanner < TemplateSystem::Record::Del
  attr_accessible :root_id, :root_type, :banner_id, :datetime_start, :datetime_stop

  belongs_to :root, polymorphic: true
  belongs_to :banner

  validates_presence_of :banner_id, :root_type, :root_id

  def to_s
    "#{I18n.l(datetime_start, format: :long)} / #{I18n.l(datetime_stop, format: :long)} / #{banner.to_s}"
  end
end

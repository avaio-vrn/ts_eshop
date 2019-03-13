# == Schema Information
#
# Table name: tovar_stocks
#
#  id             :integer          not null, primary key
#  tovar_model_id :integer
#  date_start     :datetime
#  date_end       :datetime
#  price          :float
#  content_text   :string(255)
#  del            :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TovarStocks < TemplateSystem::Record::Del
  belongs_to :tovar_model
  has_one :tovar, through: :tovar_model

  attr_accessor :tovar_id, :price_current
  attr_accessible :tovar_id, :price_current

  attr_accessible :content_text, :date_end, :date_start, :del, :price, :tovar_model_id
end

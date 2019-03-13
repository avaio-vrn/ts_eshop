class Goods::Related < ActiveRecord::Base
  def self.table_name
    'goods_related'
  end

  has_one :related, class_name: '::Tovar', primary_key: 'related_id', foreign_key: 'id'

  attr_accessible :related_id, :tovar_id
end

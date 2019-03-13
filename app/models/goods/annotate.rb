# frozen_string_literal: false

class Goods::Annotate < ActiveRecord::Base
  belongs_to :tovar, class_name: '::Tovar'

  attr_accessible :tovar_id, :content_text

  validates :content_text, length: { maximum: 250 }

  def to_s
    content_text
  end
end

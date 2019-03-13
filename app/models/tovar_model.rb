# frozen_string_literal: false

# == Schema Information
#
# Table name: tovar_models
#
#  id            :integer          not null, primary key
#  tovar_id      :integer
#  content_name  :string(255)
#  content_text  :text
#  del           :boolean
#  row_num       :integer
#  price         :float
#  use_in_new    :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  currency      :integer          default(0)
#  popular_model :boolean          default(FALSE)
#  in_stock      :boolean          default(TRUE)
#  pre_order     :boolean          default(FALSE)
#  unit          :string(20)
#  quantity      :string(10)
#  vendor_code   :string(255)
#

class TovarModel < TemplateSystem::Record::DelRowNum
  extend Concerns::SimpleSearch
  include Concerns::Content

  ROW_NUM_FIELDS = [:tovar_id].freeze
  REDIRECT_AFTER_SAVE = :tovar

  after_destroy :fix_row_num
  before_validation :normalize_image_name
  before_save :cache_price
  after_save :update_tovar_prices

  belongs_to :tovar
  has_many :tovar_models_properties, dependent: :destroy
  has_many :property_types, through: :tovar_models_properties
  has_one :section, through: :tovar
  has_one :tovar_stocks
  has_one :yandex_market, class_name: 'YandexMarket::Export', dependent: :destroy

  has_many :images, class_name: '::ImageSubdir', as: :root

  validates_presence_of :tovar_id
  validates :content_name, without_content_name: true

  scope :novelty_goods, -> { joins(:tovar).where(use_in_new: true).order(:created_at).limit(5) }
  scope :popular_goods, -> { joins(:tovar).where(popular_model: true).order(:created_at).limit(10) }
  scope :available, -> { joins(:tovar).where(discontinued: false, del: false, in_stock: true, tovars: { discontinued: false, del: false, in_stock: true }) }

  attr_accessible :content_name, :content_text, :price, :tovar_id, :in_stock, :discontinued,
    :use_in_new, :currency, :popular_model, :unit, :quantity, :vendor_code,
    :tovar_models_properties_attributes, :tovar_stocks_attributes, :images_attributes, :yandex_market_attributes
  accepts_nested_attributes_for :tovar_models_properties, allow_destroy: true
  accepts_nested_attributes_for :tovar_stocks, allow_destroy: true
  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :yandex_market, allow_destroy: true

  def self.available_hash
    { discontinued: false, del: false, in_stock: true }
  end

  def to_s
    if ::Configuration.loaded_get('main', 'tovar_model_without_content_name')
      [tovar.to_s, tovar_models_properties.pluck(:value).join('/')].join(' - ')
    else
      if content_name.blank?
        # if tovar.content_header.blank?
        [tovar.to_s, properties_to_s].join(' - ')
        # else
        #   tovar.content_header
        # end
      else
        tovar_name = tovar.to_s
        if tovar_name.match content_name
          tovar_name
        else
          [tovar.to_s, content_name].join(' ')
        end
      end
    end
  end

  def properties_to_s
    tovar_models_properties.pluck(:value).join('/')
  end

  def content_header
    content_name
  end

  def or_model(param)
    return [] if id.nil?
    har = send(param)
    har.blank? ? tovar.send(param) : har
  end

  def main_image(style = :thumb)
    id.nil? ? '/assets/no_img.png' : images.blank? ? tovar_image(style) : images[0].url(style)
  end

  def alt_for_image
    (tovar.content_header << ' ' << content_name.to_s) unless id.nil?
  end

  def stock?
    !tovar_stocks.blank?
  end

  def stock_price
    tovar_stocks.price
  end

  def currency
    super || 0
  end

  def currency_sym
    currency.zero? ? :rub : currency == 1 ? :usd : :eur
  end

  def currency_to_s
    currency.zero? ? 'Рубли' : currency == 1 ? 'Доллары' : 'Евро'
  end

  def currency_value
    if currency > 0
      require 'nokogiri'
      code = currency_sym == :eur ? 'R01239' : 'R01235'
      value = Nokogiri.XML(open(Rails.root.join('config/CBR_daily.xml')).read)
        .at("Valute[ID='#{code}']").css('Value').text.tr(',', '.').to_f
    end
    value || 1
  end

  def price_in_currency
    stock? ? stock_price : (price_with_quantity * currency_value).round(2)
  end
  alias price_in_rub price_in_currency

  def price_in_currency_before_stock
    (price_with_quantity * currency_value).round(2)
  end
  alias price_in_rub_without_stock price_in_currency_before_stock

  def ecommerce(action = 'detail', a_price = nil, h_products = {}, h_ecommerce = {})
    {
      'ecommerce' =>  {
        'currencyCode' =>  'RUB',
        action => {
          'products' => [
            { 'id' => id,
              'name' => content_name,
              'category' => section.deep_content_name,
              'price' => a_price || price }.merge(h_products)
          ]
        }
      }.merge(h_ecommerce)
    }.to_json
  end

  private

  def normalize_image_name
    require 'russian'
    images.each do |image|
      image.file_file_name = ::Russian.transliterate(image.file_file_name).downcase.gsub(/[^0-9A-Za-z\.]/, '_').gsub(/^_|__|_$/, '')
    end
  end

  def price_with_quantity
    quantity.blank? ? price.to_f : (price.to_f * quantity.to_f)
  end

  def tovar_image(style)
    tovar.image.blank? ? '/assets/no_img.png' : tovar.image.url(style)
  end

  def fix_row_num
    Admin::RowNum::Fix.new(:tovar_model, nil, { tovar_id: tovar_id }, destroyed: row_num).after_destroy!
  end

  def cache_price
    @old_price = price_in_rub
  end

  def update_tovar_prices
    new_price = price_in_rub
    changed = false
    tovar = self.tovar
    prices = tovar.tovar_models.map(&:price_in_currency)
    if tovar.min_price.nil? || new_price < tovar.min_price || !prices.include?(tovar.min_price)
      tovar.min_price = new_price
      changed = true
    end
    if tovar.max_price.nil? || new_price > tovar.max_price || !prices.include?(tovar.max_price)
      tovar.max_price = new_price
      changed = true
    end

    tovar.save! if changed
  end
end

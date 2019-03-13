# frozen_string_literal: false

# == Schema Information
#
# Table name: tovars
#
#  id              :integer          not null, primary key
#  content_name    :string(255)
#  content_header  :string(255)
#  row_num         :integer
#  del             :boolean
#  id_str          :string(70)
#  section_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  popular_product :boolean
#  pro             :boolean          default(FALSE)
#

class Tovar < TemplateSystem::Record::Base
  extend Concerns::SimpleSearch
  include Concerns::IncludeBanner

  ROW_NUM_FIELDS = [:section_id].freeze

  belongs_to :section
  has_one :annotate, class_name: '::Goods::Annotate', dependent: :destroy
  has_many :goods_relateds, class_name: '::Goods::Related', dependent: :destroy
  has_many :relateds, through: :goods_relateds
  has_many :tovars_properties, dependent: :destroy
  has_many :property_types, through: :tovars_properties
  has_many :tovar_models, dependent: :destroy
  has_many :tovar_models_properties, through: :tovar_models

  has_one :image, class_name: '::ImageSubdir', as: :root

  attr_accessible :section_id, :content_header, :content_name, :pro, :in_stock, :discontinued, :show_card,
    :tovars_properties_attributes, :image_attributes, :tovar_models_attributes, :annotate_attributes,
    :goods_relateds_attributes
  attr_accessor :show_card

  accepts_nested_attributes_for :tovars_properties, :tovar_models, allow_destroy: true,
    reject_if: proc { |attributes| attributes['property_type_id'].blank? }
  accepts_nested_attributes_for :image, :annotate, :goods_relateds, allow_destroy: true

  validates :content_name, presence: true, length: { maximum: 200 }

  default_scope includes(:tovar_models)
  scope :order_by_section_and_name, -> { joins(:section).order('sections.content_name', 'content_name') }

  def self.find(input)
    input = input.to_i if input =~ /\A\d+\z/
    input.is_a?(Integer) ? super : where(id_str: input).first
  end

  def self.available_hash(section_id)
    { discontinued: false, del: false, in_stock: true, section_id: section_id }
  end

  def to_s
    content_name.blank? ? content_header : content_name
  end

  def deep_content_name
    "#{section&.content_name} / #{content_name}"
  end

  def in_card_property_types
    @in_card_props ||= property_types.where('tovars_properties.in_card_prop = ?', true)
  end

  def main_image(style = :thumb)
    image.blank? ? '/assets/no_img.png' : image.url(style)
  end

  def price_in_currency
    min_price == max_price ? min_price : "от #{min_price}"
  end
  alias price_in_rub price_in_currency

  def or_model(param)
    send(param)
  end

  def tovar_model
    tovar_models.first
  end
  alias first_model tovar_model

  def models_count
    tovar_models.size
  end

  def have_stock?
    tovar_models.any? { |model| !model.tovar_stocks.blank? }
  end

  def first_stock
    tovar_models.find { |model| !model.tovar_stocks.blank? }
  end

  def show_action_data_hash
    return {} if all_model_property_values.blank? && tovar_models.blank?
    { g: id,
      m: current_model&.id,
      d: choiced.disable_props,
      a: choiced.available_props + [choiced.current_prop],
      ms: choiced.available_models,
      l: choiced.last_prop }
  end

  def current_model
    return nil if all_model_property_values.blank? && tovar_models.blank?
    choiced_models_get.current_model
  end

  def choiced
    choiced_models_get
  end

  def all_model_properties
    all_model_properties_get.tovar_models_properties
  end

  def all_model_property_types
    @cache_model_property_types ||= all_model_properties_get.model_property_types
  end

  def all_model_property_values
    @cache_all_model_properties_get ||= all_model_properties_get.just_property_values
  end

  def all_model_property_value_by_id(id)
    all_model_property_values[id] || []
  end

  def union_property_values
    all_model_properties_get.property_values || []
  end

  def relevant(limit = nil)
    @similar ||= similars_get.get(limit)
    if @similar.blank?
      { title: 'Новинки раздела', goods: section&.novinki(limit) }
    else
      { title: 'Похожие товары', goods: @similar }
    end
  end

  def similar_goods(limit = nil)
    similars_get.get(limit)
  end

  def choiced_models_get(args = nil)
    @choice_model || @choice_model = ::Goods::ChoiceModel.new(self, args)
  end

  def ecommerce(action = 'detail', h_products = {}, h_ecommerce = {})
    {
      'ecommerce' =>  {
        'currencyCode' =>  'RUB',
        action => {
          'products' => [
            { 'id' => id,
              'name' => content_name,
              'category' => section.deep_content_name,
              'price' => min_price }.merge(h_products)
          ]
        }
      }.merge(h_ecommerce)
    }.to_json
  end

  private

  def all_model_properties_get
    @all_model_properties || @all_model_properties = ::Goods::TovarAllPropertiesValues.new(self)
  end

  def similars_get
    @similar || @similar = Goods::Similar.new(self)
  end
end

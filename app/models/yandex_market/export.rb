# == Schema Information
#
# Table name: export_yandex_markets
#
#  id             :integer          not null, primary key
#  tovar_model_id :integer
#  description    :string(255)
#  category_id    :integer
#  prefix         :string(255)
#  model_name     :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class YandexMarket::Export < ActiveRecord::Base
  self.table_name = 'export_yandex_markets'

  belongs_to :tovar_model
  has_one :tovar, through: :tovar_model

  attr_accessible :category_id, :description, :model_name, :prefix, :tovar_model_id

  def self.save_to_file
    require 'nokogiri'

    # usd = Nokogiri.XML(open(Rails.root.join("config/CBR_daily.xml")).read)
    #   .at("Valute[ID='R01235']").css('Value').text.gsub(',','.').to_f
    # eur = Nokogiri.XML(open(Rails.root.join("config/CBR_daily.xml")).read)
    #   .at("Valute[ID='R01239']").css('Value').text.gsub(',','.').to_f
    #
    market_list = YandexMarket::Export.all
    biz_info = ::BizInfo.new

    yml_xml = Nokogiri::XML::Builder.new(encoding: "utf-8") do |xml|
      xml.doc.create_internal_subset('yml_catalog', nil, "shops.dtd")

      xml.yml_catalog(:date => Time.now.to_s(:ym)) {
        xml.shop { # описание магазина
          xml.name  biz_info.name
          xml.company biz_info.name
          xml.url biz_info.host_with_protocol
          xml.agency "Avaio Media"
          xml.email "support@avaio-media.ru"
          xml.currencies { # описание используемых валют в магазине
            xml.currency({id: "RUR", rate: "1", plus: '0' })
          }

          xml.categories {
            exists = []
            market_list.each do |market|
              category = market.tovar_model.section
              unless exists.include? category.id
                xml.category({id: category.id}){ xml << category.content_header.mb_chars.capitalize.to_s }
                exists << category.id
              end
            end
          }

          xml.offers {
            market_list.each do |market|
              product = market.tovar_model
              price = product.price_in_rub
              url = if product.tovar.tovar_models.size > 1
                      Rails.application.routes.url_helpers.tovar_model_url(product, host: biz_info.host, protocol: biz_info.protocol)
                    else
                      Rails.application.routes.url_helpers.tovar_url(product.tovar, host: biz_info.host, protocol: biz_info.protocol)
                    end

              unless price.zero?
                opt = { id: product.id, available: product.in_stock }
                xml.offer(opt) {
                  xml.url url
                  if product.tovar_stocks.blank?
                    xml.price product.price_in_rub_without_stock
                  else
                    xml.oldprice product.price_in_rub_without_stock
                    xml.price product.tovar_stocks.price
                  end
                  xml.currencyId "RUR"
                  xml.categoryId product.section.id
                  xml.market_category YandexMarket::Category.list[market.category_id][1] unless market.category_id.blank?
                  xml.picture "#{biz_info.host_with_protocol}#{product.tovar.main_image(:medium)}"
                  xml.pickup true
                  xml.delivery true
                  xml.local_delivery_cost '0'
                  if market.model_name.blank?
                    xml.name product.content_header.to_s.mb_chars.to_s
                  else
                    xml.name "#{market.prefix.to_s.mb_chars.capitalize.to_s} #{market.model_name.to_s.mb_chars.to_s}"
                    xml.model market.model_name.mb_chars.to_s
                  end

                  xml.description market.description unless market.description.blank?
                  if product.in_stock
                    sales_notes = "Оплата онлайн и по безнал. расчету."
                  else
                    sales_notes = "Необходима предоплата 50%."
                  end
                  xml.sales_notes sales_notes
                }
              end
            end
          }
        }
      }
    end.to_xml
    tfile = File.new(File.join(Rails.root, 'public', "yandex_market.xml"), "w+")
    tfile.write(yml_xml)

    tfile.close
  end
end

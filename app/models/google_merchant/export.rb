class GoogleMerchant::Export


  def self.save_to_file
    require 'nokogiri'

    market_list = YandexMarket::Export.all

    yml_xml = Nokogiri::XML::Builder.new do |xml|

      xml.rss('version'=> '2.0', 'xmlns:g'=> 'http://base.google.com/ns/1.0') do
        xml.channel do
          xml.title 'Сварной'
          xml.link "https://www.gk-nova.ru/"
          xml.description 'Выгрузка товаров для Google Merchant Center'

          market_list.each do |market|
            product = market.tovar_model
            price = product.price_in_rub
            url = if product.tovar.tovar_models.size > 1
                    Rails.application.routes.url_helpers.tovar_model_url(product, host: "www.gk-nova.ru", protocol: 'https')
                  else
                    Rails.application.routes.url_helpers.tovar_url(product.tovar, host: "www.gk-nova.ru", protocol: 'https')
                  end
            xml.item {
              xml[:g].id "proffootball_#{product.id}"
              if market.model_name.blank?
                xml.title product.content_header.mb_chars.capitalize.to_s
              else
                xml.title "#{market.prefix.mb_chars.capitalize.to_s} #{market.model_name.mb_chars.capitalize.to_s}"
              end
              xml.description market.description unless market.description.blank?
              # Оборудование и технические изделия  Принадлежности для инструментов Принадлежности для сварки
              # Оборудование и технические изделия  Инструменты Сварочные горелки
              # Бизнес и промышленность Рабочее защитное снаряжение Сварочные маски
              xml[:g].google_product_category "Оборудование и технические изделия > Принадлежности для инструментов > Принадлежности для сварки"
              xml[:g].product_type "Оборудование и технические изделия > Принадлежности для инструментов > Принадлежности для сварки"
              xml.link url
              xml[:g].image_link "https://www.gk-nova.ru#{product.tovar.main_image(:medium)}"
              xml[:g].condition 'new'
              xml[:g].availability 'in stock'
              xml[:g].price product.price_in_rub
            }
          end
        end
      end
    end.to_xml
    tfile = File.new(File.join(Rails.root, 'public', "google_merchant.xml"), "w+")
    tfile.write(yml_xml)

    tfile.close
  end
end

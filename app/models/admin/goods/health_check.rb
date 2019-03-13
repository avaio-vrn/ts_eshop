# frozen_string_literal: true

class Admin::Goods::HealthCheck
  include Rails.application.routes.url_helpers

  def initialize
    @actions = base
  end

  attr_reader :actions

  def base
    [
      { url: admin_goods_tovar_list_path, name: 'Редактирование цен', description: 'Быстрый поиск и изменение цен товаров' },
      # { url: admin_goods_banners_list_path, name: 'Размещение баннеров ', description: 'Быстрый поиск и изменение страниц с баннерами' },
      { url: new_import_pricelist_path, name: 'Загрузить прайс-лист', description: 'Обновление цен товаров из файла xls' },
      { url: admin_goods_goods_errors_path(id: 'tovars_without_models'), name: 'Товары без моделей', description: 'Список товаров без моделей(нет или помечены на удаление)' },
      { url: admin_goods_goods_errors_path(id: 'tovars_without_image'), name: 'Товары без изображения', description: 'Список товаров без главного изображения' },
      { url: admin_goods_goods_errors_path(id: 'tovar_models_without_price'), name: 'Модели товары без цены', description: 'Список моделей товаров с 0 ценой' },
      # { url: admin_goods_goods_errors_path(id: 'tovar_models_without_prop'), name: 'Модели товары c пустой характеристикой', description: 'Список моделей товаров с незаполненной характеристикой' }
    ]
  end
end

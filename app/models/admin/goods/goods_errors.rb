# frozen_string_literal: true

class Admin::Goods::GoodsErrors
  attr_reader :items

  def initialize(errors_type)
    @items = case errors_type
             when 'tovars_without_models' then tovars_without_models
             when 'tovars_without_image' then tovars_without_image
             when 'tovar_models_without_price' then tovar_models_without_price
             when 'tovar_models_without_prop' then tovar_models_without_prop
             else
               []
    end
    self
  end

  private

  def tovars_without_models
    Tovar.ordering.select { |t| t.tovar_models.not_deleted.count.zero? }
  end

  def tovars_without_image
    Tovar.ordering.select { |t| t.image.blank? }
  end

  def tovar_models_without_price
    TovarModel.where(price: [nil, 0]).ordering
  end

  def tovar_models_without_prop
  end
end

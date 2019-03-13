# frozen_string_literal: false

class Goods::ChoiceModel
  attr_reader :tovar, :current_model, :disable_props, :current_prop, :last_prop, :available_props, :available_models

  def initialize(tovar, args = {})
    @tovar = tovar
    @opts = args || {}
    args.blank? ? initial : choiced_get
    self
  end

  def current_model
    @current_model || @current_model = find_model_record
  end

  private

  def initial
    if @tovar.all_model_property_types.blank?
      first_model_get
    else
      initial_props
      available_models_get
      current_model_get
    end
  end

  def choiced_get
    choiced_prop = @opts['pt'].to_i
    @opts['choiced'][@opts['pt']] = @opts['val']
    @disable_props = @tovar.all_model_property_types.take_while { |e| e[:id] != choiced_prop }.map(&:id).compact
    @disable_props << choiced_prop

    @available_props = @tovar.all_model_property_types.map(&:id) - @disable_props
    @current_prop = @available_props.shift
    @last_prop = choiced_prop if @available_props.blank?

    available_models_get
    current_model_get
  end

  def initial_props
    @disable_props = []
    disable_props_get
    props
    true
  end

  def disable_props_get
    i = 0
    loop do
      @disable_props << @tovar.all_model_property_values.keys[i]
      i += 1
      break if @tovar.all_model_property_types.size == i || @tovar.all_model_property_values[@disable_props.last].to_a.size > 1
    end
    @disable_props.compact!
  end

  def props
    @available_props = @tovar.all_model_property_values.keys - @disable_props
    @current_prop = @disable_props.pop
  end

  def available_models_get
    @available_models = all_model_property_values(@disable_props&.first || @current_prop)
    @disable_props.drop(1).each do |prop|
      @available_models &= all_model_property_values(prop)
    end
  end

  def first_model_get
    @available_models = @tovar.tovar_models.available.map(&:id)
    @available_props = []
    @find_model = @tovar.tovar_models.available.first
    @current_model = @find_model
  end

  def current_model_get
    @find_model = @available_models
    @find_model &= all_model_property_values(@current_prop) unless @opts['choiced']
    @available_props.each do |prop|
      next if @tovar.all_model_property_values[prop].blank?
      @find_model &= @tovar.all_model_property_values[prop].values[0]
    end
    @find_model = @find_model.first if @find_model.is_a? Array
  end

  def all_model_property_values(prop, current_prop = false)
    if @opts['choiced'].blank? || current_prop
      @tovar.all_model_property_values[prop]&.values&.first
    else
      @tovar.all_model_property_values[prop][@opts['choiced'][prop.to_s].to_s]
    end
  end

  def find_model_record
    @tovar.all_model_properties.select { |e| e.tovar_model_id == @find_model }&.first&.tovar_model
  end
end

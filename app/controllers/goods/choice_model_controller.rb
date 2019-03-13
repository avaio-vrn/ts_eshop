# frozen_string_literal: false

class Goods::ChoiceModelController < ApplicationController
  def show
    @tovar = ::Tovar.find(params['choice_attr']['g'])
    @tovar.choiced_models_get(params['choice_attr'])
    respond_to do |format|
      format.js { render @tovar.current_model ? 'show' : 'error' }
    end
  end
end

$('.js__goods-wrap').data(<%= raw @tovar.show_action_data_hash.to_json %>)
$('.js__goods-price').html('<%= j render "/tovars/price", goods: @tovar.current_model %>')
setChoicesProp()

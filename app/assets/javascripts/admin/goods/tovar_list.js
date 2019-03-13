$('.js__result').off('click').on('click', function(e) {
  if ($(e.target).hasClass('js__save-price')) {
  var btn = $(e.target);
    var request = $.ajax({
      url: '/admin/goods/tovar_list',
      method: 'PUT',
      dataType: 'script',
      data: {
        id: $(e.target).closest('.template').data('id'),
        price: $(e.target).closest('.template').find('.js__price').val()
      },
      timeout: 5000
    });
    request.success(function(xhr) {
      showFlashMessage('<span class="flash-icon flash--apply"></span><div class="notice">Запись обновлена</div>')
      btn.remove();
    });
    request.error(function(xhr) {
      showFlashMessage('<span class="flash-icon flash--error"></span><div class="notice">Ошибка обновления записи</div>')
    })
  }
})

$('.js__result').bind('input', function(e) {
  var adminStroke = $(e.target).closest('.js__goods-row');
  if (adminStroke.find('.js__save-price').length == 0) {
    adminStroke.append('<div class="c-2"><span class="ts-icons ts-icon-btn icon-save js__save-price"></span></div>');
  }
});
$('.js__result').off('keyup').on('keyup', function(e) {
console.log(e)
});

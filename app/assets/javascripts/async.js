//= require button
//= require client/ts_async
//= require au_user/ts_async

$(document).ready(function() {
  var el = $(".js__button");
  el.each(function() {
    initButton.apply(this);
  })

  $('.js__order-1-click').click(function() {
    $.ajax({
      url: '/order/quick/new?type_name=goods&type_id=' + $(this).data('id'),
      dataType: 'script'
    })
  })

});

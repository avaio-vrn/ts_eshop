var simpleSearchCallback = function() {

  $('.js__save').off('click').on('click', function(e) {
    var elem = e.target,
      wrapper = elem.closest('.admin-stroke'),
      index = wrapper.dataset.index;


    if (index != undefined) {
      var today = new Date(),
        tomorrow = new Date();
      tomorrow.setDate(today.getDate() + 1);
      $.ajax({
          url: '/pages_banners',
          method: 'POST',
          dataType: 'script',
          data: {
            pages_banner: {
              banner_id: window.location.pathname.match(/\d$/g)[0],
              root_type: window.tsSimpleSearchData.data[index].record['model'],
              root_id: window.tsSimpleSearchData.data[index].record['id'],
              datetime_start: today.toUTCString(),
              datetime_stop: tomorrow.toUTCString()
            }
          }
        })
        .error(function(jqXHR, textStatus, errorThrown) {
          console.log('error')
        })
        .success(function(data, textStatus, jqXHR) {
          $(wrapper).remove();
        })
    }
  })

}

$('.js__destroy').off('click').on('click', function(e) {
  var elem = e.target,
    wrapper = elem.closest('.admin-stroke'),
    index = wrapper.dataset.index;

  e.preventDefault();
  e.stopPropagation();

  if ((index != undefined) && (confirm("УДАЛИТЬ?") == true)) {
    $.ajax({
        url: '/pages_banners/' + window.iconsData.data[index].record['id'],
        method: 'DELETE',
        dataType: 'JSON'
      })
      .error(function(jqXHR, textStatus, errorThrown) {
        console.log('error')
      })
      .success(function(data, textStatus, jqXHR) {
        $(wrapper).remove();
      })
  }
})

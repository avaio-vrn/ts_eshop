var searchAjax = function(page) {
  var elem = document.querySelector('.js__simple-search-input');

  $.ajax({
    url: '/admin/simple_search',
    method: 'GET',
    dataType: 'script',
    data: {
      search_str: $(elem).val(),
      model: $(elem).data('model'),
      partial: $(elem).data('partial'),
      in_section: $(elem).closest('.template').find('.js__simple-search-in-section').prop("checked") ? 1 : 0,
      section_id: $(elem).closest('.template').find('.js__simple-search-section').val(),
      page: page
    }
  })
}

$('.js__simple-search-input').off('keyup').on('keyup', function(e) {
  if ($(e.target).val().length > 2) {
    searchAjax();
  }
})


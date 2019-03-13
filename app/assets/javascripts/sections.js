function $_GET(param) {
  var vars = {};
  window.location.href.replace(location.hash, '').replace(
    /[?&]+([^=&]+)=?([^&]*)?/gi,
    function(m, key, value) {
      vars[key] = value !== undefined ? value : '';
    }
  );

  if (param) {
    return vars[param] ? vars[param] : null;
  }
  return vars;
}


$('.ch-o-link').click(function() {
  $('.ch-option').toggleClass('ch-active');
});

$('.ch-o-li').click(function() {
  $.ajax({
    url: location.protocol + '//' + location.host + window.location.pathname.replace(/\/change-view\/(cards|list)/, '') + '/set_per_page',
    dataType: 'script',
    type: 'POST',
    data: {
      per_page: $(this).text(),
      url: window.location.pathname
    },
    cache: false
  }).done(function() {
    window.location.replace(window.location.pathname);
  });
});

$('.js__view-button').click(function(e) {
  if ($(e.currentTarget).hasClass('view-button--active')) {
    return false;
  }
  var url;
  if ($(e.currentTarget).hasClass('view-button--list')) {
    url = location.protocol + '//' + location.host + window.location.pathname + '/change-view/list'
  } else {
    url = location.protocol + '//' + location.host + window.location.pathname + '/change-view/cards'
  }
  $.ajax({
    dataType: 'script',
    url: url,
    type: 'GET',
    cache: false,
    success: function() {
      // window.location.replace(window.location.pathname);
    }
  });
});


var getFilterValues = function() {
  var inputsValues = $.map($('.goods-prop-active'), function(obj) {
    var name = $(obj).closest('.filter-checkboxs').find('.goods-prop-title');
    return {
      val: $(obj).text(),
      pt: name.data('pt-id'),
      type_name: name.text()
    };
  });
  var slidersValues = $('.filter-slider').filter(function(i, handlesSlider) {
    var val = handlesSlider.noUiSlider.get();
    if (parseFloat(val[0]) == parseFloat($(handlesSlider).data('min')) &&
      parseFloat(val[1]) == parseFloat($(handlesSlider).data('max'))) {
      return false
    } else {
      return this
    }
  });
  if (inputsValues == undefined) {
    inputsValues = []
  }

  slidersValues = $.map(slidersValues, function(handlesSlider) {
    var name = $(handlesSlider).closest('.filter-checkboxs').find('.goods-prop-title');
    var val = handlesSlider.noUiSlider.get();
    return {
      val: val,
      pt: name.data('pt-id'),
      type_name: name.text()
    }
  })
  if (slidersValues.length == 0) {
    slidersValues = []
  }

  return {
    page: $_GET('page'),
    values: inputsValues,
    slidersValues: slidersValues
  }
}

$('.js__filter-show').off('click').on('click', function(e) {
  $('body').addClass('filter-show');

  if ($('.js__filter-ctn .js__filter-hide').length == 0) {
    $('.js__filter-ctn').append('<span class="js__filter-hide filter-hide"></span>')
  }

  $('.js__filter-hide').off('click').on('click', function(e) {
    $('body').removeClass('filter-show');
  })
});

$('.filter-container').on('click', function(e) {
  if ($(e.target).hasClass('goods-prop-value')) {
    $(e.target).toggleClass('goods-prop-active')
    $.ajax({
      dataType: 'script',
      url: '/filters/' + $('.filter-container').data('sc-id'),
      method: 'post',
      data: getFilterValues(),
      success: function() {}
    })
  }
});

$(document).ready(function() {
  $.map($('.filter-slider'), function(handlesSlider) {
    // var inputs = [handlesSlider.nextSibling, handlesSlider.nextSibling.nextSibling]
    noUiSlider.create(handlesSlider, {
      start: [parseFloat($(handlesSlider).data('min')), parseFloat($(handlesSlider).data('max'))],
      connect: true,
      tooltips: [true, true],
      range: {
        'min': [parseFloat($(handlesSlider).data('min'))],
        'max': [parseFloat($(handlesSlider).data('max'))]
      }
    });
    // handlesSlider.noUiSlider.on('update', function( values, handle ) {
    //   inputs[handle].value = values[handle];
    // });
    //

    handlesSlider.noUiSlider.on('end', function() {
      $.ajax({
        dataType: 'script',
        url: '/filters/' + $('.filter-container').data('sc-id'),
        method: 'post',
        data: getFilterValues(),
        success: function() {}
      })
    })
  })
});

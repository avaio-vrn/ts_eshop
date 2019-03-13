var propertyContainer = document.querySelector('.js__goods-choice-model');
var wrapper = $(propertyContainer).closest('.js__goods-wrap');
propertyContainer.addEventListener('click', function(event) {
  if (event.target.classList.contains('js__goods-model-prop') && !(event.target.classList.contains('goods-prop-active') || event.target.classList.contains('goods-prop-disable'))) {
    var goods = wrapper.data('g'),
      choiced_obj = {};
    [].slice.call(document.querySelectorAll('.goods-prop-active')).map(function(item, i, a) {
      choiced_obj[item.parentNode.getAttribute('data-pt')] = item.innerText;
    })
    $.ajax({
      url: '/tovars/' + goods + '/goods/choice_model',
      method: 'GET',
      dataType: 'script',
      data: {
        choice_attr: {
          g: wrapper.data('g'),
          pt: event.target.parentNode.getAttribute('data-pt'),
          val: event.target.innerText,
          choiced: choiced_obj
        }
      }
    })
  }
})

var setChoicesProp = function() {
  var propertyContainers = document.getElementsByClassName('goods-prop-values'),
    disableProperties = wrapper.data('d'),
    availableProperties = wrapper.data('a'),
    canChoice = wrapper.data('ms'),
    currentModel = wrapper.data('m'),
    lastProperty = wrapper.data('l');

  function includes(arr, big_arr) {
    return arr.filter(function(val) {
      return big_arr.indexOf(val) !== -1;
    })
  }

  $.map(propertyContainers, function(container) {
    $.map(container.getElementsByClassName('js__goods-model-prop'), function(elem) {
      if ($.inArray(currentModel, $(elem).data('tm')) > -1) {
        $(elem).addClass('goods-prop-active')
      } else {
        $(elem).removeClass('goods-prop-active')
        if ($(container).data('pt') != lastProperty) {
          if ($.inArray($(container).data('pt'), disableProperties) > -1) {
            $(elem).addClass('goods-prop-disable')
          } else {
            if (($.inArray($(container).data('pt'), availableProperties) > -1) && !includes($(elem).data('tm'), canChoice).length > 0) {
              $(elem).addClass('goods-prop-disable')
            }
          }
        }
      }
    })
  })
}

$(document).ready(function() {
  setChoicesProp()
})

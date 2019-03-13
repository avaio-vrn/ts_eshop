// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require utils/init
//= require jquery
//= require jquery_ujs
//= require magnific-popup
//= require rails.validations
//= require client/form_trans_label
//= require spinner
//= require lemmon_slider

$(document).ready(function() {
  $('.popular-slider').lemmonSlider({
    'controls': '.slider-controls',
    'controlsNext': false,
    'infinite': true
  });

  $('.js__basket-add').on('basketAdd', function(event) {
    initButton.apply($($('.js__cart').find('.js__button')[0]));
  });

  $('.js__cart-bottom-submit').click(function() {
    $('form.js__cart-bottom').submit();
  })

  $('.js__page-banner').on('click', function() {
    $(document).scrollTop($('.promo').offset().top - $('nav').height() - 20)
  })

  currentMenuLink = document.querySelector('.goods-catalog-ul [href="' + document.location.pathname + '"]')
  if (currentMenuLink != undefined) {
    currentMenuLink.classList.add("nav-link-section-current");
  }
});

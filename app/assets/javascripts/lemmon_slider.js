/*
 * Lemmon Slider - jQuery Plugin
 * Simple and lightweight slider/carousel supporting variable elements/images heights.
 *
 * Examples and documentation at: http://jquery.lemmonjuice.com/plugins/slider-variable-heights.php
 *
 * Version: 0.3 (21/12/2015)
 * Requires: jQuery v1.4+
 *
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 */
(function( $ ){

  var _css = {};

  var methods = {
    //
    // Initialzie plugin
    //
    init : function(options){

      var options = $.extend({}, $.fn.lemmonSlider.defaults, options);

      return this.each(function(){

        var $slider = $( this ),
          data = $slider.data( 'slider' );

        if ( ! data ){

          var $sliderContainer = $slider.find(options.slider),
            $sliderControls = options.contorlsNext ? $slider.next().filter(options.controls) : $slider.prev().filter(options.controls),
            $items = $sliderContainer.find( options.items ),
            originalHeight = 1;

          $items.each(function(){ originalHeight += $(this).outerHeight(true); });
          $sliderContainer.height( originalHeight );

          // slide to last item
          if ( options.slideToLast ) $sliderContainer.css( 'padding-right', $slider.height() );

          // infinite carousel
          if ( options.infinite ){
            $slider.attr('data-slider-infinite',true);

            originalHeight = originalHeight * 3;
            $sliderContainer.height( originalHeight );

            $items.clone().addClass( '-after' ).insertAfter( $items.filter(':last') );
            $items.filter( ':first' ).before( $items.clone().addClass('-before') );

            $items = $sliderContainer.find( options.items );

          }

          $slider.items = $items;
          $slider.options = options;

          // first item
          //$items.filter( ':first' ).addClass( 'active' );

          // attach events
          $slider.bind( 'nextSlide', function( e, t ){

            var scroll = $slider.scrollTop();
            var x = 0;
            var slide = 0;

            $items.each(function( i ){
              if ( x == 0 && $( this ).position().top > 1 ){
                x = $( this ).position().top + parseFloat($( this ).css('marginBottom'));
                slide = i;
              }
            });

            if ( x > 0 && $sliderContainer.outerHeight() - scroll - $slider.height() - x > 0 ){
              slideTo( e, $slider, scroll+x, slide, 'fast' );
            } else if ( options.loop ){
              // return to first
              slideTo( e, $slider, 0, 0, 'slow' );
            }

          });
          $slider.bind( 'prevSlide', function( e, t ){

            var scroll = $slider.scrollTop();
            var x = 0;
            var slide = 0;

            $items.each(function( i ){
              if ( $( this ).position().top + parseFloat($( this ).css('marginTop')) < 0 ){
                x = $( this ).position().top + parseFloat($( this ).css('marginTop'));
                slide = i;
              }
            });

            if ( x ){
              slideTo( e, $slider, scroll+x, slide, 'fast' );
            } else if ( options.loop ){
              // return to last
              var a = $sliderContainer.outerHeight() - $slider.height();
              var item = $($items[0]);
              var heightItem = item.height() + parseFloat(item.css('marginTop')) + parseFloat(item.css('marginBottom'))
              var countSlide = Math.ceil($slider.height() / heightItem);
              var b;
              slide = $items.size() - countSlide;
              b = $($items[slide]).position().top  + parseFloat($($items[slide]).css('marginTop'));
              if ( a > b ){
                slideTo( e, $slider, b, slide, 'fast' );
              } else {
                slideTo( e, $slider, a, slide, 'fast' );
              }
            }

          });
          $slider.bind( 'nextPage', function( e, t ){

            var scroll = $slider.scrollTop();
            var w = $slider.height();
            var x = 0;
            var slide = 0;

            $items.each(function( i ){
              if ( $( this ).position().top < w ){
                x = $( this ).position().top;
                slide = i;
              }
            });

            if ( x > 0 && scroll + w + 1 < originalHeight ){
              slideTo( e, $slider, scroll+x, slide, 'slow' );
            } else if ( options.loop ){
              // return to first
              slideTo( e, $slider, 0, 0, 'slow' );
            }

          });
          $slider.bind( 'prevPage', function( e, t ){

            var scroll = $slider.scrollTop();
            var w = $slider.height();
            var x = 0;

            $items.each(function( i ){
              if ( $( this ).position().top < 1 - w ){
                x = $( this ).next().position().top;
                slide = i;
              }
            });

            if ( scroll ){
              if ( x == 0 ){
                //$slider.animate({ 'scrollTop' : 0 }, 'slow' );
                slideTo( e, $slider, 0, 0, 'slow' );
              } else {
                //$slider.animate({ 'scrollTop' : scroll + x }, 'slow' );
                slideTo( e, $slider, scroll+x, slide, 'slow' );
              }
            } else if ( options.loop ) {
              // return to last
              var a = $sliderContainer.outerHeight() - $slider.height();
              var b = $items.filter( ':last' ).position().top;
              if ( a > b ){
                $slider.animate({ 'scrollTop' : b }, 'slow' );
              } else {
                $slider.animate({ 'scrollTop' : a }, 'slow' );
              }
            }

          });
          $slider.bind( 'slideTo', function( e, i, t ){

            slideTo(
              e, $slider,
              $slider.scrollTop() + $items.filter( ':eq(' + i +')' ).position().top,
              i, t );

          });

          // controls
          $sliderControls.find( '.viewed-next-slide' ).click(function(){
            $slider.trigger( 'nextSlide' );
            return false;
          });
          $sliderControls.find( '.viewed-prev-slide' ).click(function(){
            $slider.trigger( 'prevSlide' );
            return false;
          });
          $sliderControls.find( '.next-page' ).click(function(){
            $slider.trigger( 'nextPage' );
            return false;
          });
          $sliderControls.find( '.prev-page' ).click(function(){
            $slider.trigger( 'prevPage' );
            return false;
          });

          //if ( typeof $slider.options.create == 'function' ) $slider.options.create();

          $slider.data( 'slider', {
            'target'  : $slider,
            'options' : options
          });

        }

      });

    },
    //
    // Add Item
    //
    addItem : function(options){
      var options = $.extend({}, $.fn.lemmonSlider.defaults, options);

      var $slider = $( this ),
        $sliderContainer = $slider.find(options.slider),
        $sliderControls = options.contorlsNext ? $slider.next().filter(options.controls) : $slider.prev().filter(options.controls),
        $items = $sliderContainer.find( options.items );

      options.infinite = $slider.attr('data-slider-infinite');

      if (!options.item) { return false }
      methods.destroy.apply(this);
      if (options.prepend) {
        $sliderContainer.prepend(options.item);
      } else {
        $sliderContainer.append(options.item);
      }
      methods.init.apply( this, [options]);
    },
    //
    // Destroy plugin
    //
    destroy : function(){

      return this.each(function(){

        var $slider = $( this ),
          $sliderControls = options.contorlsNext ? $slider.next().filter(options.controls) : $slider.prev().filter(options.controls),
          $items = $slider.find('> *:first > *'),
          data = $slider.data( 'slider' );

        $slider.unbind( 'nextSlide' );
        $slider.unbind( 'prevSlide' );
        $slider.unbind( 'nextPage' );
        $slider.unbind( 'prevPage' );
        $slider.unbind( 'slideTo' );

        $sliderControls.find( '.viewed-next-slide' ).unbind( 'click' );
        $sliderControls.find( '.viewed-prev-slide' ).unbind( 'click' );
        $sliderControls.find( '.next-page' ).unbind( 'click' );
        $sliderControls.find( '.next-page' ).unbind( 'click' );

        $slider.removeData( 'slider' );

        if ($slider.attr('data-slider-infinite')) {
          $.merge($items.filter('.-before'),$items.filter('.-after')).each(function(index,item){
            $(item).remove();
          });
        }
      });

    }
    //
    //
    //
  };
  //
  // Private functions
  //
  function slideTo( e, $slider, x, i, t ){

    $slider.items.filter( 'li:eq(' + i + ')' ).addClass( 'active' ).siblings( '.active' ).removeClass( 'active' );

    if ( typeof t == 'undefined' ){
      t = 'fast';
    }
    if ( t ){
      $slider.animate({ 'scrollTop' : x }, t, function(){
        checkInfinite( $slider );
      });
    } else {
      var time = 0;
      $slider.scrollTop( x );
      checkInfinite( $slider );
    }

    //if ( typeof $slider.options.slide == 'function' ) $slider.options.slide( e, i, time );

  }
  function checkInfinite( $slider ){

    var $active = $slider.items.filter( '.active' );
    if ( $active.hasClass( '-before' ) ){

      var i = $active.prevAll().size();
      $active.removeClass( 'active' );
      $active = $slider.items.filter( ':not(.-before):eq(' + i + ')' ).addClass( 'active' );
      $slider.scrollTop( $slider.scrollTop() + $active.position().top );

    } else if ( $active.hasClass( '-after' ) ){

      var i = $active.prevAll( '.-after' ).size();
      $active.removeClass( 'active' );
      $active = $slider.items.filter( ':not(.-before):eq(' + i + ')' ).addClass( 'active' );
      $slider.scrollTop( $slider.scrollTop() + $active.position().top );

    }

  }
  //
  //
  //
  $.fn.lemmonSlider = function( method , options ){
    if (options == null) { options = {}; };
    if ( methods[method] ) {
      return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || !method ){
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.lemmonSlider' );
    }

  };
  //
  //
  //
  $.fn.lemmonSlider.defaults = {

    'items'       : '> *',
    'loop'        : true,
    'slideToLast' : false,
    'slider'      : '> *:first',
    // since 0.2
    'infinite'    : false,
    'controls'    : '.controls',
    'controlsNext'    : true

  };

})( jQuery );

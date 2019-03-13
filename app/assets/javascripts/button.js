/* Version 0.3.3
 * assoc - Change element with change button
 * assoc-c - Element change state css class
 * active_class - Button change state css class
 * close - false - don't close after document click
 *
 */
;(function(){
  var clickButton = function(){
    var button = $(this);
    var buttonContainerName = $(this).data('container') || '.button-container';
    var buttonContainer = button.closest(buttonContainerName);
    if(buttonContainer.length == 0){
      buttonContainer = button.parent().find(buttonContainerName);
      if(buttonContainer.length == 0){
        buttonContainer = button.parent().parent().find(buttonContainerName);
      }
    }

    var stateActive = false;
    var assoc = $(this).data('assoc');
    var assoc_class = $(this).data('assoc-c') || 'active';
    var active_class = $(this).data('active') || 'button-active';
    var inactiveClass = $(this).data('inactive') || 'inactive';
    var btn_active = $('.button-active');
    var assocClose = $(this).data('close');

    var updateAfterClick = function(e){
      var currButton = $(this);
      if($('.button-active').length != 0) {
        $.map($('.button-active'), function(activeButton){
          if(activeButton != currButton[0]) { return false; }
          if((!$(activeButton).context.assocElem.is(e.target) && !insideObject(buttonContainer[0], e.target)) ||
             $(e.target).closest('.overlay').length > 0 || $(e.target).hasClass('js__button-close') ||
             $(e.target).closest('.js__button').length > 0)
          {
            $(activeButton).removeClass(active_class);
            $(activeButton).removeClass('button-active');
            currButton.context.assocElem.removeClass(assoc_class);
            stateActive = false;
            $(document).off('click', documentClick);
            $('.js__button').off('click', documentClick);
            $('.js__button-close').off('click', documentClick);
            $(window).trigger('jsButtonClose', $(activeButton));
          }
        });
      }
    };
    var documentClick = updateAfterClick.bind(this);

    function clickButtonEvent(event) {
      if (assoc === undefined) this.assocElem = $('body');
      else {
        if(assoc === 'this') this.assocElem = button;
        else{
          this.assocElem = buttonContainer.find('.' + assoc);
        }
      }
      stateActive = !stateActive

      event.preventDefault();
      event.stopPropagation();

      if(assocClose == undefined || assocClose == 'true'){
        if(stateActive) {
          $('.js__button').off('click', documentClick).on('click', documentClick);
          $('.js__button-close').off('click', documentClick).on('click', documentClick);
          $(document).off('click', documentClick).on('click', documentClick);
          $(window).trigger('jsButtonOpen', button);
        }
        else {
          $('.js__button').off('click', documentClick)
          $('.js__button-close').off('click', documentClick);
          $(document).off('click', documentClick);
          $(window).trigger('jsButtonClose', button);
        }
      }

      if (stateActive){
        button.addClass('button-active');
        button.addClass(active_class);
        button.removeClass(inactiveClass);
      }
      else {
        button.addClass(inactiveClass);
        button.removeClass(active_class);
        button.removeClass('button-active');
      }

      this.assocElem.toggleClass(assoc_class);

    }
    button.off('click', clickButtonEvent).on('click', clickButtonEvent);
  };

  var insideObject = function(container, finding_obj){
    var node = finding_obj.parentNode;
    while (node != null) {
      if (node == container) {
        return true;
      }
      node = node.parentNode;
    }
    return false;
  }

  window.initButton = function(){
    clickButton.apply(this);
  }
})();

$.spinner = {
  html_spinner: "<div class='upload-spinner'><span class='spin-1'></span><span class='spin-2'></span><span class='spin-3'></span></div>",
  create: function(elem, where, find_and_del){
    if(find_and_del != undefined) { this.remove(); }
    if (elem == undefined) $('.js__spinner').append(this.html_spinner);
    else {
      if(where == undefined) $(elem).append(this.html_spinner);
      else $(elem).before(this.html_spinner);
    }
  },
  show: function(transparent){
    var obj = $('.upload-spinner');
    if(transparent != undefined) { obj.addClass('upload-spinner--transparent') }
    obj.fadeIn();
  },
  hide: function(){ $('.upload-spinner').fadeOut(); },
  remove: function(){ $('.upload-spinner').remove(); $('.js__spinner').removeClass('js__spinner'); }
}


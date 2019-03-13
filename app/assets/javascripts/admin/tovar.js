function dropdown(elem, init){
  elem.select2({
    placeholder: function(){
      return "Выберите значение"
    },
    minimumInputLength: 1,
    tags: true,
    tokenSeparators: ['\n', '\t'],
    createSearchChoice: function(term, data) {
      if ($(data).filter(function() {
        return this.text.localeCompare(term) === 0;
      }).length === 0) {
        return {
          id: term,
          text: term
        };
      }
    },
    maximumSelectionSize:1,
    ajax: {
      type: "GET",
      url : location.protocol+'//'+location.host+"/property_types",
      dataType: 'json',
      quietMillis: 100,
      data: function (term, page) { // page is the one-based page number tracked by Select2
        return {
          q: term, //search term
          page_limit: 10, // page size
          page: page
        };
      },
      results: function (data, page){
        return {results: $.map(data, function(owner, i){
          return { id: owner.id, text: owner.content_name }
        })};
      }
      },
      initSelection: function(element, callback) {
        if (init){
          var id=$(element).val();
          if (id!=="") {
            $.ajax(location.protocol+'//'+location.host+"/property_types/"+id, {
              type: "GET",
              data: {},
              dataType: "json"
            }).done(function(data) { callback({ id: data.id, text: data.content_name }) });
          }
        };
      },
      dropdownCssClass: "bigdrop", // apply css that makes the dropdown taller
      escapeMarkup: function (m) { return m; } // we do not want to escape markup since we are displaying html in results
    });
};

$(document).ready(function() {
  dropdown($(".property-dropdown"), true);
  $(".property-types").bind('cocoon:after-insert', function(event, insertedItem) {
    dropdown(insertedItem.find(".property-dropdown"), false);
    insertedItem.find('.select2-input').focus();
  });
});

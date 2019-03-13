$('.js__filter-text').text('<%= @filter_string %>')

<% if @goods.blank? %>
  $('.goods-content > .items').html('')
<% else %>
  $('.goods-content > .items').html('<%= j render partial: "/sections/#{@partial}", collection: @goods, as: :goods %>')
  <% if @with_page %>
    $('.pagination-footer').show();
  <% else %>
    $('.pagination-footer').hide();
  <% end %>

  basketAddInit();
<% end %>

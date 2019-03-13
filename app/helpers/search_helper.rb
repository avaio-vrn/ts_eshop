module SearchHelper
  def render_search_form
    form_tag('/search', method: :get, class:'search-form'.freeze) do
      text_field_tag(:search_f, nil, class: 'search-input'.freeze, placeholder: 'Поиск по наименованию или артикулу'.freeze) <<
      button_tag('', class:'search-submit'.freeze, name: nil)
    end
  end
end

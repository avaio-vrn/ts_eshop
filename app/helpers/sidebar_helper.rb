module SidebarHelper
  def h_sidebar_render
    if params[:id]&.to_sym == :kontakty
      ''
    else
      [delivery, payment, contacts].sample
    end
  end

  private

  def delivery
    sidebar_block(:delivery) do
      content_tag(:p,'Собственным автотранспортом') <<
      content_tag(:p,'А также транспортными компаниями') <<
      content_tag(:ul, class:'list rhomb') do
        concat(content_tag(:li, 'ООО «Деловые линии»'))
        concat(content_tag(:li, 'Компания «ПЭК»'))
        concat(content_tag(:li, 'Автотрейдинг'))
        concat(content_tag(:li, '«ЖелДорЭкспедиция»'))
      end
    end
  end

  def payment
    sidebar_block(:payment) do
      content_tag(:p, 'Онлайн', class: :header) <<
      content_tag(:p,'Банковские карты, электронные деньги, оплата при помощи терминалов (благодаря платежному сервису Яндекс.Касса)') <<
      content_tag(:p, 'Безналичные', class: :header) <<
      content_tag(:p,'Для юридических лиц - получение счета для оплаты')
    end
  end

  def contacts
    sidebar_block(:contacts) do
      content_tag(:p, 'Телефоны', class: :header) <<
      content_tag(:p,'(473) 292-32-13, +7(920) 212-53-21') <<
      content_tag(:p, 'Адрес', class: :header) <<
      content_tag(:p,'г.Воронеж, ул.Кольцовская, д.56') <<
      content_tag(:p, 'Время работы', class: :header)
    end
  end

  def sidebar_block(type, &block)
    content_tag :div, class: "sidebar-block c-12 #{type}" do
      yield
    end
  end
end

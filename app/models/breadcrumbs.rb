#version 0.2.3
class Breadcrumbs
  include Rails.application.routes.url_helpers

  def initialize(item, options = {})
    @path = []
    @item = item
    @item.is_a?(Symbol) || @item.is_a?(String) ? index_current : show_current

    while @md && !@item.nil? && !BREADCRUMBS[@md].nil?
      if @with_show_for_parent && !BREADCRUMBS[@md][:parent].blank?
        @item = @item.send(BREADCRUMBS[@md][:parent].to_s.singularize)
        @path.push(name: @item.content_name_to_s,
                   path: BREADCRUMBS[@md][:path] || polymorphic_path(@item))
      end
      unless BREADCRUMBS[@md].has_key? :no_index
        @path.push(name: BREADCRUMBS.dig(@md, :name) || I18n.t(:header_h1, scope: [@md, :index]),
                   path: BREADCRUMBS[@md][:path] || polymorphic_path(@md))
      end
      break if @item.is_a?(Symbol) || @item.nil?
      @md = BREADCRUMBS[@md][:parent]
    end
    @path.push(name: BREADCRUMBS[:home_page], path: root_path) if options[:with_root]
    @path.reverse!
  end

  def render
    html = ActionController::Base.helpers.link_to(BREADCRUMBS[:home_page], root_path, class: block_given? ? yield(:css) : 'breadcrumbs-link') <<
    @path.inject(''.html_safe) { |a, e| a << ' / '.html_safe.concat(
      ActionController::Base.helpers.link_to(e[:name], e[:path], class: block_given? ? yield(:css) : 'breadcrumbs-link')
    )}
    html << " / <span>#{@current}</span>".html_safe if @current
    return html
  end

  private

  def index_current
    @current = BREADCRUMBS.dig(@item,:name) || I18n.t(:header_h1, scope: [@item, :index])
    @md = BREADCRUMBS.dig(@item, :parent)
  end

  def show_current
    @item = @item.first if @item.is_a? ActiveRecord::Relation
    with_show_for_parent?
    @current = @item.content_name if @item.respond_to? :content_name
    return nil if BREADCRUMBS[@md].nil?

    while !BREADCRUMBS[@md].has_key?(:name) && !BREADCRUMBS[@md][:parent].nil? && !@item.nil?
      @md = BREADCRUMBS[@md][:parent]
      @with_show_for_parent = BREADCRUMBS[@md].has_key? :parent_name
      if @with_show_for_parent
        @item = @item.send(@md.to_s.singularize)
        unless @item.nil?
          @path.push(name: @item.content_name,
                     path: BREADCRUMBS[@md][:path] || polymorphic_path(@item))
        end
      end
    end
  end

  def with_show_for_parent?
    @md = @item.is_a?(Symbol) ? @item : @item.class.to_s.pluralize.underscore.to_sym
    @with_show_for_parent = BREADCRUMBS[@md]&.has_key? :parent_name
  end
end

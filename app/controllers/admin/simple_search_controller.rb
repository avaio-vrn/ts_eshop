# frozen_string_literal: false

class Admin::SimpleSearchController < ApplicationController
  authorize_resource class: false

  def index
    @admin_panel = Admin::Panel::Base.new(:simple_search)
    respond_to do |format|
      if params[:search_str]
        format.js { render 'index', locals: { partial: partial_get, records: records_get }}
      else
        format.html
      end
    end
  end

  private

  def records_get
    case params['model']
    when 'goods'; goods_get
    when 'pages_goods'; pages_and_goods_get
    else pages_get
    end
  end

  def goods_get
    (Tovar.simple_search(params[:search_str], params['page'], scope_get) +
     TovarModel.simple_search(params[:search_str], params['page'], nil, :price).map(&:tovar)
    ).uniq_by(&:id)
  end

  def pages_and_goods_get
    Tovar.simple_search(params[:search_str], params['page'], scope_get) + pages_get
  end

  def pages_get
      Section.simple_search(params[:search_str], params['page'])
    # Page.simple_search(params[:search_str]) +
    #   Section.simple_search(params[:search_str]) +
    #   PageSection.simple_search(params[:search_str])
  end

  def scope_get
    params['in_section'] == '1' ? Tovar.arel_table[:section_id].eq(params[:section_id]) : nil
  end

  def partial_get
    case params['partial']
    when 'tovar_list'; '/admin/goods/tovar_list/simple_search_result'
    when 'pages_banner'; '/banners/simple_search_result'
    end
  end
end

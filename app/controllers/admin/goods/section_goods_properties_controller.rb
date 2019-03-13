# frozen_string_literal: false

class Admin::Goods::SectionGoodsPropertiesController < ApplicationController
  authorize_resource class: false

  def edit
    @admin_panel = ::Admin::Panel::Base.new
    @admin_panel.from(controller_name, action_name)

    @section_goods_property = Admin::Goods::SectionGoodsProperty.new
    @section_goods_property.section_id = params['id']

    render 'new_edit'
  end

  def create
    section_goods_property = Admin::Goods::SectionGoodsProperty.new
    section_goods_property.params = params
    section_goods_property.save

    respond_to do |format|
      format.html { redirect_to section_url(Section.find(params['admin_goods_section_goods_property']['section_id'])) }
    end
  end
end

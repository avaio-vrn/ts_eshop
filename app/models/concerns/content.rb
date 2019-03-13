# -*- encoding : utf-8 -*-
module Concerns
  module Content
    extend ActiveSupport::Concern

    included do
      before_create :create_content_association

      has_one :content, as: :contentable, class_name: TemplateSystem::Content, dependent: :destroy
      has_many :templates,  through: :content
      has_one :image, class_name: Files::Image, as: :root
      has_one :restrict, class_name: ::Restrict, as: :root 

      attr_accessible :image_attributes
      accepts_nested_attributes_for :image, allow_destroy: true

      private

      def create_content_association
        build_content
        true
      end
    end

  end
end

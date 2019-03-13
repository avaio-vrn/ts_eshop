module Concerns::IncludeBanner
  extend ActiveSupport::Concern

  included do
    has_many :pages_banner, as: :root
    has_many :banners, through: :pages_banner
  end

  def banner
    banners.first.image.url(:original) unless self.banners.blank?
  end

  module ClassMethods

  end
end

# frozen_string_literal: false
# == Schema Information
#
# Table name: files
#
#  id                :integer          not null, primary key
#  root_type         :string(255)
#  root_id           :integer
#  row_num           :integer
#  del               :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#

class ImageSubdir < Files::Image
  has_attached_file :file,
                    styles: ->(instance) { c_styles(instance.instance.file_content_type) },
                    convert_options: ->(instance) { c_options[instance] },
                    processors: ->(instance) { instance.svg? ? [] : ['thumbnail'.to_sym] },
                    url: '/images/library:library_id/:id/:style_:filename',
                    path: ':rails_root/public/images/library:library_id/:id/:style_:filename',
                    default_url: '/assets/no_img.png'
end

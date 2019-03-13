# frozen_string_literal: false
Paperclip.interpolates :library_id do |attachment, _style|
  obj = attachment.instance
  if obj.root_type == 'Tovar' && obj.root&.section_id
    "/sc_#{obj.root.section_id}"
  elsif obj.root_type == 'TovarModel' && obj.root&.tovar&.section_id
    "/sc_#{obj.root.tovar.section_id}"
  else
    ''
  end
end

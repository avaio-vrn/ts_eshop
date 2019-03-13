class Properties::RootsTypes < TemplateSystem::Record::DelRowNum
  belongs_to :type
  belongs_to :root, polymorphic: true

  scope :by_params, ->(params) { where(root_type: params[:root_type], root_id: params[:root_id]) }

  validates_presence_of :root_type, :root_id

  attr_accessible :root_id, :root_type, :type_id

  def to_s
    type.to_s
  end
end

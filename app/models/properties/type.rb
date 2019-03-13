class Properties::Type < TemplateSystem::Record::Del
  has_many :roots_types, as: :root
  has_many :roots, through: :roots_types
  has_many :types_values
  has_many :values, through: :types_values

  scope :ordering, -> { order(:content_name) }

  attr_accessible :content_name, :value_type

  validates :content_name, presence: true

  def self.value_type_collection
    [[0, 'Строковое'], [1, 'Числовое'], [2, 'Логическое(да/нет)']]
  end

  def self.by_params(params)
    ::Properties::RootsTypes.where(root_type: params[:root_type], root_id: params[:root_id]).map(&:type)
  end

  def to_s
    content_name
  end
end

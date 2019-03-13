class Properties::TypesValues < TemplateSystem::Record::DelRowNum
  ROW_NUM_FILEDS = [:root_type, :root_id, :type_id]

  before_save :col_num_set

  belongs_to :root, polymorphic: true
  belongs_to :type
  belongs_to :value

  scope :by_params, ->(params) { where(root_type: params[:root_type], root_id: params[:root_id]) }
  scope :ordering, -> { order(:type_id, :col_num) }

  validates_presence_of :root_type, :root_id

  attr_accessible :root_id, :root_type, :type_id, :value_id, :col_num

  def self.root_get(params)
    params[:root_type].classify.constantize
  end

  def to_s
    "#{type.to_s} : #{value.to_s}"
  end


  private

  def col_num_set
    all_records = Properties::TypesValues.where(root_type: self.root_type, root_id: self.root_id)
    if all_records.size == 0
      self.col_num = 1
    else
      self.col_num = all_records.maximum('col_num')
      all_types = Properties::RootsTypes.where(root_type: self.root_type, root_id: self.root_id)
      self.col_num += 1 if all_records.size % all_types.size == 0
    end
  end
end

class ImportPricelist < Object
  def initialize(tempfile)
    @tempfile = tempfile
    @errors = []
    @count = 0
  end

  def errors
    @errors
  end

  def count
    @count
  end

  def save
    require 'roo'
    xlsx = Roo::Excelx.new(@tempfile)
    data = []
    xlsx.each_row_streaming(pad_cells: true) do |row|
      data << { id: row[0]&.value, content_name: row[1]&.value, price: row[2]&.value }
    end
    models = TovarModel.where(id: data.map{ |e| e[:id] })
    data.each_with_index do |row, i|
      next if row[:id].blank? && row[:content_name].blank? && row[:price].blank?
      if row[:id].blank?
        @errors << { row: i + 1, errors: 'На заполнено поле id' }
      else
        row.delete_if { |_k, v| v.to_s.strip == '' }
        current_model = models.where(id: row[:id])&.first
        if current_model.blank?
          @errors << { row: i + 1, errors: 'Не найдено значение id' }
        else
        if current_model.update_attributes(row.select{ |k, _v| [:id, :price].include? k })
          @count += 1
        else
          @errors << { row: i + 1, errors:  current_model.errors }
        end
        end
      end
    end
    self
  end
end

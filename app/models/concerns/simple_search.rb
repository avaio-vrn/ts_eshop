module Concerns::SimpleSearch

  def simple_search(query, page=nil, scope=nil, column_array=[:content_name, :content_header], limit=10)
    column_array = [column_array] unless column_array.is_a? Array
    wild_query = "%#{query.downcase}%"

    records = []

    column_array.each do |column|
      match = case columns_hash[column.to_s].type
              when :string
                arel_table[column].lower.matches(wild_query)
              when :float, :integer
                if (query =~ /\A[+-]?\d+\.?\d+\z/ )
                  arel_table[column].eq(query)
                else
                  nil
                end
              else
                nil
              end
      if match
        records += if scope
                     where(scope).where(match)
                   else
                     where(match).page(page)
                   end
      end
    end

    Kaminari.paginate_array(records.uniq).page(page).per(limit)
  end

end

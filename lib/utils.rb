module Utils

  module Currency

    # Lookup a currency symbol
    # i.e symbol(:gbp) => "£"
    def self.symbol(curr)
      Money.new(1, curr).symbol
    end
  end

  module Date
    # Format date as human readable
    def self.humanize(date)
      date.strftime("%B %d, %Y")
    end
  end

  # Export Active Record model as a CSV file
  #
  # param model an active record model
  # param exclusions an array of attributes to exclude from csv
  #
  # - Example
  #
  #   excluding id and first_name from csv export
  #
  #   Utils.render_csv @user, [:id, :first_name]
  #
  def self.render_csv(model, exclusions=[])
    CSV.generate do |csv|
      columns = model.column_names.reject do |c|
        exclusions.include?(c.to_sym)
      end
      csv << columns
      model.all.each do |m|
        values = columns.map do |column|
          m.send column.to_sym
        end
        csv << values
      end
    end
  end
end

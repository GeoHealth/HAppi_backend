class ChangeDateTypeInOccurrences < ActiveRecord::Migration
  def self.up
    change_column :occurrences, :date, 'timestamp USING CAST(date AS timestamp without time zone)'
  end

  def self.down
    change_column :occurrences, :date, :text
  end
end

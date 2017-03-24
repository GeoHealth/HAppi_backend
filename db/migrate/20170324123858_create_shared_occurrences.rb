class CreateSharedOccurrences < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :email
      t.timestamp :expiration_date
      t.string :token
      t.belongs_to :user, index: true
    end

    create_table :shared_occurrences do |t|
      t.belongs_to :reports, index: true
      t.belongs_to :occurrences, index: true
    end
  end
end

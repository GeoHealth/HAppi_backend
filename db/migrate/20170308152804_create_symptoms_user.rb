class CreateSymptomsUser < ActiveRecord::Migration
  def change
    create_table :symptoms_users do |t|
      t.references :user, index: true
      t.references :symptom, index: true
    end
    add_foreign_key :symptoms_users, :users
    add_foreign_key :symptoms_users, :symptoms
  end
end

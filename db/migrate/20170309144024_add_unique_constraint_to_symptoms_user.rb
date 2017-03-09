class AddUniqueConstraintToSymptomsUser < ActiveRecord::Migration
  def change
    add_index :symptoms_users, [:user_id, :symptom_id], unique: true
  end
end

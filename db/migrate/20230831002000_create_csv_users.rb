# frozen_string_literal: true

class CreateCsvUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_users do |t|
      t.string :file_id
      t.string :external_id
      t.string :phone
      t.string :passport
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :birth_date
      t.text :info
      t.boolean :is_phone_verified
      t.boolean :is_passport_verified
      t.string :is_phone_verified_source
      t.string :is_passport_verified_source
    end

    add_index :csv_users, :phone
    add_index :csv_users, :passport
  end
end

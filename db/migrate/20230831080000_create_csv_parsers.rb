# frozen_string_literal: true

class CreateCsvParsers < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_parsers do |t|
      t.integer :file_id
      t.integer :rows
      t.integer :is_phone_verified_count
      t.integer :is_passport_verified_count
      t.integer :external_id
      t.integer :phone
      t.integer :passport
      t.integer :last_name
      t.integer :first_name
      t.integer :middle_name
      t.integer :birth_date
      t.boolean :saved
      t.string :headers
      t.string :separator
    end
  end
end

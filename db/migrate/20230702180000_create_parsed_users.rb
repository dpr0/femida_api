# frozen_string_literal: true

class CreateParsedUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :parsed_users do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :birth_date
      t.string :passport
      t.string :phone
      t.string :address
      t.string :is_phone_verified

      t.timestamps null: false
    end
  end
end

# frozen_string_literal: true

class CreateFemidaRetroUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :femida_retro_users do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :phone
      t.string :birth_date
      t.string :passport
      t.string :is_passport_verified
      t.string :is_phone_verified

      t.timestamps null: false
    end
  end
end

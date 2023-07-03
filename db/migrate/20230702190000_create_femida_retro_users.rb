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
      t.boolean :is_passport_verified
      t.boolean :is_phone_verified
    end
  end
end

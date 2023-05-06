# frozen_string_literal: true

class CreateSro < ActiveRecord::Migration[7.0]
  def change
    create_table :sro do |t|
      t.integer :number
      t.string :full_name
      t.string :inn
      t.string :ogrn
      t.string :address
      t.string :website
      t.string :phone
      t.string :email

      t.timestamps null: false
    end
  end
end

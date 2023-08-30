# frozen_string_literal: true

class CreateSample03 < ActiveRecord::Migration[7.0]
  def change
    create_table :sample_03 do |t|
      t.integer :external_id
      t.string :phone
      t.string :passport
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :birth_date
      t.text :resp
      t.boolean :is_phone_verified
    end

    add_index :sample_03, :phone
    add_index :sample_03, :passport
  end
end

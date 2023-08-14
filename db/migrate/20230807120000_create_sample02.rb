# frozen_string_literal: true

class CreateSample02 < ActiveRecord::Migration[7.0]
  def change
    create_table :sample_02 do |t|
      t.integer :customer_id
      t.string :phone
      t.string :passport
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :birth_date
      t.text :resp
    end

    add_index :sample_02, :phone
    add_index :sample_02, :passport
  end
end

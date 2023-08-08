# frozen_string_literal: true

class CreateSample01 < ActiveRecord::Migration[7.0]
  def change
    create_table :sample_01 do |t|
      t.string :phone
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :birth_date
      t.string :source
      t.string :year
    end

    add_index :sample_01, :phone
  end
end

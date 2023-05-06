# frozen_string_literal: true

class CreateOpendata < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata do |t|
      t.string :number
      t.string :status
      t.string :rows
      t.string :filename
      t.timestamps null: false
      t.datetime :deleted_at
    end
  end
end

# frozen_string_literal: true

class CreateOpendataNalog77 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_nalog77 do |t|
      t.string :name
    end
  end
end

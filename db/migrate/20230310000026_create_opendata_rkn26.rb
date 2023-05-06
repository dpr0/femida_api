# frozen_string_literal: true

class CreateOpendataRkn26 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn26 do |t|
      t.string :entryNum
      t.string :entryDate
      t.string :serviceName
      t.string :owner
    end
  end
end

# frozen_string_literal: true

class CreateOpendataRkn20 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn20 do |t|
      t.string :entryNum
      t.string :entryDate
      t.string :distributorName
      t.string :distributorOGRN
      t.string :distributorINN
      t.string :distributorLegalAddress
      t.string :distributorEmail
      t.string :distributorPersons
      t.string :services
    end
  end
end

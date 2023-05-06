# frozen_string_literal: true

class CreateOpendataRkn10 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn10 do |t|
      t.string :Num
      t.string :Date
      t.string :Owner
      t.string :Place
      t.string :Type
      t.string :DateFrom
      t.string :DateTo
      t.string :SuspensionInfo
      t.string :RenewalInfo
      t.string :AnnulledInfo
    end
  end
end

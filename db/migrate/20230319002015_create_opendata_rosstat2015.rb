# frozen_string_literal: true

class CreateOpendataRosstat2015 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rosstat2015 do |t|
      t.string :name
      t.string :okpo
      t.string :okopf
      t.string :okfs
      t.string :okved
      t.string :inn
      t.string :measure
      t.string :type
    end
  end
end

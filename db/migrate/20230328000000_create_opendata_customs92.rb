# frozen_string_literal: true

class CreateOpendataCustoms92 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_customs92 do |t|
      t.string :vehicle_vin
      t.string :start_date
      t.string :vehicle_from_country
      t.string :vehicle_from_country_naim
      t.string :vehicle_body_number
      t.string :vehicle_chassis_number
    end
  end
end

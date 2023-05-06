# frozen_string_literal: true

class CreateOpendataRkn5 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn5 do |t|
      t.string :regno
      t.string :org_name
      t.string :short_org_name
      t.string :location
      t.string :license_num
      t.string :geo_zone
      t.string :order_num
      t.string :cancellation_num
      t.string :order_date
      t.string :cancellation_date
    end
  end
end

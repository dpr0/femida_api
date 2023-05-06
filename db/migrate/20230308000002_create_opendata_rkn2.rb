# frozen_string_literal: true

class CreateOpendataRkn2 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn2 do |t|
      t.string :name
      t.string :ownership
      t.string :name_short
      t.string :addr_legal
      t.string :licence_num
      t.string :lic_status_name
      t.string :service_name
      t.string :territory
      t.string :registration
      t.string :date_start
      t.string :date_end
    end
  end
end

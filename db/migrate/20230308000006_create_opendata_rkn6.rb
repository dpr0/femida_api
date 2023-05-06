# frozen_string_literal: true

class CreateOpendataRkn6 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn6 do |t|
      t.string :pd_operator_num
      t.string :enter_date
      t.string :enter_order
      t.string :status
      t.string :name_full
      t.string :inn
      t.string :address
      t.string :income_date
      t.string :territory
      t.string :purpose_txt
      t.string :basis
      t.string :rf_subjects
      t.string :encryption
      t.string :transgran
      t.string :db_country
      t.string :is_list
      t.string :resp_name
      t.string :startdate
      t.string :stop_condition
      t.string :enter_order_num
      t.string :enter_order_date
    end
  end
end

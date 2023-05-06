# frozen_string_literal: true

class CreateOpendataRkn13 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn13 do |t|
      t.string :plan_year
      t.string :org_name
      t.string :address
      t.string :address_activity
      t.string :ogrn
      t.string :inn
      t.string :date_reg
      t.string :date_last
      t.string :goal
      t.string :date_start
      t.string :work_day_cnt
      t.string :control_form
      t.string :orgs
    end
  end
end

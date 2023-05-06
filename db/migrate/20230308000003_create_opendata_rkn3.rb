# frozen_string_literal: true

class CreateOpendataRkn3 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn3 do |t|
      t.string :name
      t.string :rus_name
      t.string :reg_number
      t.string :status_comment
      t.string :langs
      t.string :form_spread
      t.string :territory
      t.string :territory_ids
      t.string :staff_address
      t.string :domain_name
      t.string :founders
      t.string :reg_number_id
      t.string :status_id
      t.string :form_spread_id
      t.string :reg_date
      t.string :annulled_date
      t.string :suspension_date
      t.string :termination_date
    end
  end
end

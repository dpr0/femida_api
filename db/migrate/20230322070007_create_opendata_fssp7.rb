# frozen_string_literal: true

class CreateOpendataFssp7 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_fssp7 do |t|
      t.string :name
      t.string :address
      t.string :actual_address
      t.string :number_proceeding
      t.string :date_proceeding
      t.string :total_number_proceedings
      t.string :doc_type
      t.string :doc_date
      t.string :doc_number
      t.string :docs_object
      t.string :execution_object
      t.string :complete_reason_date
      t.string :departments
      t.string :departments_address
      t.string :debtor_tin
      t.string :tin_collector
    end
  end
end

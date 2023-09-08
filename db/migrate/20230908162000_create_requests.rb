# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.string :service
      t.string :response
      t.string :phone
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :birth_date
      t.string :info
      t.timestamps null: false
    end

    add_index :requests, :phone
  end
end

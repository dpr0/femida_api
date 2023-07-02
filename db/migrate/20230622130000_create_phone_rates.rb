# frozen_string_literal: true

class CreatePhoneRates < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_rates do |t|
      t.string :phone
      t.float  :rate
      t.string :status

      t.timestamps null: false
    end
  end
end

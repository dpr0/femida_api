# frozen_string_literal: true

class CreateExpiredPassports < ActiveRecord::Migration[7.0]
  def change
    create_table :expired_passports do |t|
      t.string :passp_series
      t.string :passp_number
    end
  end
end

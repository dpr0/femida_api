# frozen_string_literal: true

class CreateSroKinds < ActiveRecord::Migration[7.0]
  def change
    create_table :sro_kinds do |t|
      t.integer :sro_id
      t.integer :sro_member_id
      t.string :kind
      t.date :start_date
      t.date :end_date

      t.timestamps null: false
    end
  end
end

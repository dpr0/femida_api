# frozen_string_literal: true

class CreateSroMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :sro_members do |t|
      t.integer :sro_id
      t.string :full_name
      t.string :inn
      t.string :ogrn

      t.timestamps null: false
    end
  end
end

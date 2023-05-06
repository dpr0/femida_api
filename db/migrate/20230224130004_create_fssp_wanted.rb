# frozen_string_literal: true

class CreateFsspWanted < ActiveRecord::Migration[7.0]
  def change
    create_table :fssp_wanted do |t|
      t.string :last_name
      t.string :first_name
      t.string :patronymic
      t.string :birthday
      t.string :region_id
    end
  end
end

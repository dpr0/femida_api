# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.string :phone
      t.string :email
      t.string :birthday
      t.string :card
    end

    add_index :cards, :phone
  end
end

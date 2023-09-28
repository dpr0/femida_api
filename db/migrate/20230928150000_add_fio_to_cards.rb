# frozen_string_literal: true

class AddFioToCards < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :last_name, :string
    add_column :cards, :first_name, :string
    add_column :cards, :middle_name, :string
  end
end

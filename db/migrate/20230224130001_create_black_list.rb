# frozen_string_literal: true

class CreateBlackList < ActiveRecord::Migration[7.0]
  def change
    create_table :black_list do |t|
      t.string :last_name
      t.string :first_name
      t.string :patronymic
      t.string :birthday
    end
  end
end

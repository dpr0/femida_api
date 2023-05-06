# frozen_string_literal: true

class CreateTerroristList < ActiveRecord::Migration[7.0]
  def change
    create_table :terrorist_list do |t|
      t.string :last_name
      t.string :first_name
      t.string :middlename
      t.string :date_of_birth
    end
  end
end

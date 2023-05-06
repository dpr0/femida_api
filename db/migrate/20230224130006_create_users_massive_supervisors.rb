# frozen_string_literal: true

class CreateUsersMassiveSupervisors < ActiveRecord::Migration[7.0]
  def change
    create_table :users_massive_supervisors do |t|
      t.string :g1
      t.string :g2
      t.string :g3
      t.string :g4
      t.string :g5
    end
  end
end

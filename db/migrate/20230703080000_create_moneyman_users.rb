# frozen_string_literal: true

class CreateMoneymanUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :moneyman_users do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :phone
      t.string :passport
    end
  end
end

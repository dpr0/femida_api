# frozen_string_literal: true

class AddFieldsToTurbozaimUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :turbozaim_users, :is_phone_verified_2, :boolean
    add_column :turbozaim_users, :is_passport_verified_2, :boolean
  end
end

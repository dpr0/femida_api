# frozen_string_literal: true

class CreateGatewayAccountInfo < ActiveRecord::Migration[7.0]
  def change
    create_table 'gateway.account_info' do |t|
      t.integer :account_id
      t.string :name
      t.boolean :paying
      t.timestamps null: false
    end
  end
end

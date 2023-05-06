# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients, id: false do |t|
      t.uuid :id
      t.string :login
      t.string :password
      t.string :description
      t.string :jwt_token
      t.integer :request_count
      t.string :config
    end
  end
end

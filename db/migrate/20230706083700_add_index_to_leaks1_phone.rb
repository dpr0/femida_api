# frozen_string_literal: true

class AddIndexToLeaks1Phone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :lukoil_txt, :phone, algorithm: :concurrently
  end
end

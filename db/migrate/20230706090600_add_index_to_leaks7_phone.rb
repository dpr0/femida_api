# frozen_string_literal: true

class AddIndexToLeaks7Phone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :kinokassa_ru_orders, :phone, algorithm: :concurrently
  end
end

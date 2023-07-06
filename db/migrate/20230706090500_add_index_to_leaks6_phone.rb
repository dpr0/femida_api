# frozen_string_literal: true

class AddIndexToLeaks6Phone < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :oriflame_ru, :phone, algorithm: :concurrently
  end
end

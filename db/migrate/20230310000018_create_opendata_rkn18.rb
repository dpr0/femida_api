# frozen_string_literal: true

class CreateOpendataRkn18 < ActiveRecord::Migration[7.0]
  def change
    create_table :opendata_rkn18 do |t|
      t.string :name
      t.string :email
      t.string :education
      t.string :degree
      t.string :expertiseSubject
      t.string :accreditationDate
      t.string :orderNum
      t.string :validity
      t.string :status
    end
  end
end

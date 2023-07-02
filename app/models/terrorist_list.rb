# frozen_string_literal: true

# == Schema Information
#
# Table name: terrorist_list
#
#  id            :bigint           not null, primary key
#  date_of_birth :string
#  first_name    :string
#  last_name     :string
#  middlename    :string
#
class TerroristList < ApplicationRecord
  self.table_name = :terrorist_list
end

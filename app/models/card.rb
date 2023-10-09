# == Schema Information
#
# Table name: cards
#
#  id          :bigint           not null, primary key
#  birthday    :string
#  card        :string
#  email       :string
#  first_name  :string
#  last_name   :string
#  middle_name :string
#  phone       :string
#
# Indexes
#
#  index_cards_on_phone  (phone)
#
class Card < ApplicationRecord
end

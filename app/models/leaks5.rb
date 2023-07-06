# frozen_string_literal: true

# == Schema Information
#
# Table name: one_more_lz2
#
#  Car        :text
#  DayBirth   :text
#  FirstName  :text
#  Info       :text
#  Inn        :text
#  LastName   :text
#  MiddleName :text
#  MonthBirth :text
#  Passport   :text
#  Snils      :text
#  Telephone  :text
#  YearBirth  :text
#  index      :text
#
# Indexes
#
#  index_one_more_lz2_on_Telephone  (Telephone)
#  ix_lz2_index                     (index)
#
# index
# LastName
# FirstName
# MiddleName
# DayBirth
# MonthBirth
# YearBirth
# Telephone
# Car
# Passport
# Snils
# Inn
# Info
class Leaks5 < ApplicationRecord
  self.table_name = :one_more_lz2
end

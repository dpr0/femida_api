# frozen_string_literal: true

class Api::Femida::WhooshController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/whoosh', 'Пользователи whoosh - csv'
  def index
    file = File.read(Rails.root.join('tmp', 'whoosh', 'whoosh-small-users.json'))
    data = JSON.parse(file)
    array = data.map { |u| { name: u['name'], phone: u['phone'], email: u['email'] } }
    array.each_slice(30000) do |slice|
      User.insert_all(slice)
    end
    file = CSV.generate do |csv|
      csv << ['name', 'phone', 'email']
      array.each { |data| csv << [data[:name], data[:phone], data[:email]] }
    end
    send_data(file, filename: 'response.csv', type: 'text/csv')
  end
end

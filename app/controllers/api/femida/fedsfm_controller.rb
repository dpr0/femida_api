# frozen_string_literal: true

class Api::Femida::FedsfmController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/fedsfm/:fio', 'fedsfm'
  def index
    with_error_handling do
      array = []
      dfs = DatesFromString.new
      resp = RestClient.get('https://www.fedsfm.ru/documents/terrorists-catalog-portal-act').body
      parsed_data = Nokogiri::HTML.parse(resp)
      parsed_data.css('#russianFL').css('.terrorist-list').children.each do |t|
        text = t.children.text
        next if text.blank?

        z = text.split(',').first.split('. ').last.tr('*', '').split(' ')
        terrorist = TerroristList.find_or_initialize_by(
          last_name:  z[0],
          first_name: z[1],
          middlename: z[2],
          date_of_birth: dfs.find_date(text).first&.to_date&.strftime('%d.%m.%Y')
        )
        array << terrorist unless terrorist.id
      end
      array.map(&:save)
      array
    end
  end
end

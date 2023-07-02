# frozen_string_literal: true

class Api::Femida::FsspWantedController < ApplicationController
  protect_from_forgery with: :null_session

  HOST = 'https://fssp.gov.ru'

  api :GET, '/fssp_wanted', 'Экспорт должников'
  def index
    with_error_handling do
      dfs = DatesFromString.new
      array = []
      get('/api/kss-wanted/regions/show/', parse: true, host: HOST)['data'].each do |data|
        get("/api/kss-wanted/debtors/list?region_id=#{data['id']}", parse: true, host: HOST)['data'].each do |d|
          z = d['fio'].tr(',', '').split(' ')
          ['<br>', 'ОСП', 'по', 'г.', 'р.', 'г.р.', 'м.р.', 'года', 'рождения', 'рождения)', '(разыскивается', 'району', 'району)']
            .each { |x| z.delete x }
          wanted = FsspWanted.find_or_initialize_by(
            last_name:  z[0],
            first_name: z[1],
            patronymic: z[2],
            birthday:   d['birthday'] || dfs.find_date(d['fio']).first&.to_date&.strftime('%d.%m.%Y'),
            region_id:  data['title']
          )
          array << wanted unless wanted.id
        end
      end
      array.map(&:save)
      array
    end
  end
end

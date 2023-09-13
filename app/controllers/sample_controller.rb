# frozen_string_literal: true

class SampleController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?

  def index
    user = params['csv_user'].permit!.to_h.reject { |_, value| value.blank? } if params['csv_user'].present?
    @csv_user = CsvUser.new
    @results = user ? PersonService.instance.search(user)['data'] : []
    @requests_results = user ? Request.where(user) : []
    @parsed_user_results = user ? ParsedUser.where(user) : []
    if user && (@results.present? || @requests_results.present? || @parsed_user_results.present?)
      pasp1 = @results.map { |x| x['ПАСПОРТ'] }.compact.uniq
      pasp2 = @parsed_user_results.map(&:passport).compact.uniq
      @inn = (pasp1 + pasp2).uniq.map do |pasp|
        if user['last_name'] && user['first_name'] && user['middle_name'] && user['birth_date']
          inn = InnService.call(
            f: user['last_name'],
            i: user['first_name'],
            o: user['middle_name'],
            date: user['birth_date'],
            passport: pasp
          )['inn']
        end
        { passport: pasp, inn: inn }
      end.compact
    end
  end
end

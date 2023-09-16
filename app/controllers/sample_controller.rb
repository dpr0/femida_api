# frozen_string_literal: true

class SampleController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?

  def index
    user = params['csv_user'].permit!.to_h.reject { |_, value| value.blank? } if params['csv_user'].present?
    @csv_user = CsvUser.new
    return unless user

    if user[:phone].present? && user[:birth_date].present? && user[:last_name].present? && user[:first_name].present? && user[:middle_name].present?
      @okb_result = OkbService.call(
        telephone_number: user[:phone],
        birthday: user[:birth_date],
        surname: user[:last_name].downcase,
        name: user[:first_name].downcase,
        patronymic: user[:middle_name].downcase
      )
    end

    req_params = user.slice(*%i[phone last_name first_name middle_name birth_date])
    @requests_results = Request.where(req_params) if req_params.present?
    @parsed_user_results = ParsedUser.where(req_params) if req_params.present?

    limit = params.delete(:limit)
    offset = params.delete(:offset)
    user.merge!(limit: limit) if limit
    user.merge!(offset: offset) if offset
    user[:birthdate] = user.delete(:birth_date) # !!
    response = PersonService.instance.search(user)
    @results = response['data']

    pasp1 = @results.present? ? @results.map { |x| x['ПАСПОРТ'] }.compact.uniq : []
    pasp2 = @parsed_user_results.present? ? @parsed_user_results.map(&:passport).compact.uniq : []
    @inn = (pasp1 + pasp2).uniq.first(5).map do |pasp|
      if user[:last_name] && user[:first_name] && user[:middle_name] && user[:birthdate]
        inn = InnService.call(
          f: user[:last_name],
          i: user[:first_name],
          o: user[:middle_name],
          date: user[:birthdate],
          passport: pasp
        )['inn']
      end
      { passport: pasp, inn: inn }
    end.compact
  end
end

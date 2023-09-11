# frozen_string_literal: true

class SampleController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?

  def index
    user = params['csv_user'].permit!.to_h.reject { |_, value| value.blank? } if params['csv_user'].present?
    @csv_user = CsvUser.new
    @results = user ? PersonService.instance.search(user)['data'] : {}
  end
end

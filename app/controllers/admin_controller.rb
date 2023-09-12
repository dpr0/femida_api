# frozen_string_literal: true

class AdminController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!
  before_action :is_admin?

  def index
    @request_count = `grep '=========== Verify REQUEST: ============' log/production.log -c`
    @balane_kapcha = RestClient.get("#{URL}/res.php?key=#{ENV['RUCAPTCHA_KEY']}&action=getbalance")&.to_i
  end
end

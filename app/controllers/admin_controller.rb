# frozen_string_literal: true

class AdminController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  def index
    if current_user&.admin?
      @dt = Request::OKB_IMPORT_DATE
      @old_request_count = Request::OKB_LOST_REQUESTS + Request.where("created_at < '#{@dt}'").count
      @request_count = Request.where("created_at > '#{@dt}'").count
      @balance_kapcha = RestClient.get("#{URL}/res.php?key=#{ENV['RUCAPTCHA_KEY']}&action=getbalance")&.to_i
      @req_per_day = @request_count / ((Date.current - @dt.to_date).to_i + 1)
    end
  end
end

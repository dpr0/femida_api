# frozen_string_literal: true

class Api::Femida::SroController < ApplicationController
  protect_from_forgery with: :null_session

  api :GET, '/sro', 'Единый реестр саморегулируемых организаций в сфере финансового рынка'
  def index
    time = Time.current
    workbook = Roo::Spreadsheet.open(load_file)
    workbook.sheets.each do |worksheet|
      workbook.sheet(worksheet).each_row_streaming do |row|
        r = row.map(&:value)
        next if ['ИНН', 3].include? r[2]

        @inn = r[2] unless r[2].nil?

        if %w[Действующие Прекращенные].include? worksheet
          sro = Sro.find_or_initialize_by(inn: @inn)
          sro.assign_attributes(number: r[0], full_name: r[1], ogrn: r[3], address: r[4], website: r[5], phone: r[6], email: r[7]) if r.compact.size == 11
          sro.save if sro.inn.present?
          next unless sro.id

          kind = SroKind.find_or_initialize_by(sro_id: sro.id, kind: r[8])
          kind.assign_attributes(start_date: r[9], end_date: (r[10] if r[10] != 'Ссылка'))
          kind.save(validate: false) if kind.sro_id.present? && kind.kind.present?
        else
          member = SroMember.find_or_initialize_by(inn: @inn)
          member.assign_attributes(sro_id: Sro.find_by(number: worksheet).id, full_name: r[1], ogrn: r[3])
          member.save if member.inn.present?

          kind = SroKind.find_or_initialize_by(sro_member_id: member.id, kind: r[4])
          kind.save(validate: false) if kind.sro_member_id.present? && kind.kind.present?
        end
      end
    end
    render status: :ok, json: { sro: Sro.count, members: SroMember.count, kind: SroKind.count, time: Time.current - time }
  end

  private

  def load_file
    path = Tempfile.new(['temp_sro', '.xlsx']).path
    File.binwrite(path, RestClient.get('https://cbr.ru/vfs/finmarkets/files/supervision/list_sro.xlsx'))
    path
  end
end

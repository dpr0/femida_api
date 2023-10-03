class CsvParserInnJob < ApplicationJob
  queue_as :default

  def perform(hash)
    ParserService.new(self.class.name, hash['id'], :passport).call
  end
end

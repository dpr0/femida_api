class CsvParserCardJob < ApplicationJob
  queue_as :default

  def perform(hash)
    ParserService.new(self.class.name, hash[:id], :card).call
  end
end

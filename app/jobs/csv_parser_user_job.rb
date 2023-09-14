class CsvParserUserJob < ApplicationJob
  queue_as :default

  def perform(hash)
    ParserService.new(self.class.name, hash[:id], :phone).call
  end
end

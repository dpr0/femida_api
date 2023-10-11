class ScoreService

  HOST = 'https://femida-search.online/internal/fraud/batch/'.freeze

  def initialize(parser_id)
    @file = ActiveStorage::Attachment.find_by(id: parser_id)
    @parser = CsvParser.find_by(file_id: parser_id)
  end

  def upload
    response = RestClient.post("#{HOST}upload", multipart: true, upload: @file)
    uuid = JSON.parse(response.body)[:uuid]
    @parser.update(score_uuid: uuid)
  end

  def check
    JSON.parse get(@uuid)
    #   { status: string,
    #     total: int,
    #     completed: int,
    #     failed: int }
  end

  def download
    response = get "#{@uuid}/download"
    # Результаты можно скачивать, не дожидаясь завершения обработки
    # При засылке параметра score_status="failed" будет отдан файл с сфейлившимися номерами

  end

  def retry
    response = get "#{@uuid}/rerun"
    # Будет перезапущен скоринг телефонов, по которым он еще не выполнялся или упал с ошибкой.
  end

  def destroy
    response = RestClient.delete("#{HOST}#{@uuid}")

  end

  private

  def get(path)
    response = RestClient.get("#{HOST}#{path}")

  end
end

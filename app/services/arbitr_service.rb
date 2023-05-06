class ArbitrService
  def initialize(inn, wasm, pr_fp)
    @inn = inn.to_s
    @wasm = wasm
    @pr_fp = pr_fp
  end

  def call
    resp = send_request
    return unless resp

    parsed_data = Nokogiri::HTML.parse(resp)
    parsed_data.css('tr').map do |x|
      text = parsed_data.css('.administrative span').children[0].text
      date = DatesFromString.new.find_date(text).first
      dt = begin
             date&.to_date ? date.to_date.strftime('%d.%m.%Y') : ''
           rescue
             nil
           end
      link  = parsed_data.css('.num_case')[0].attributes['href'].value
      num   = parsed_data.css('.num_case').children[0].text.delete("\r\n\t\s")
      judge = parsed_data.css('.court .b-container .judge').children[0].text
      title = parsed_data.css('.court .b-container div:not(.judge)').children[0].text
      name  = parsed_data.css('.js-rollover.b-newRollover').children[0].text.delete("\r\n\t").split.join(' ')
      { link: link, num: num, judge: judge, title: title, name: name, dt: dt }
    end
  end

  private

  def send_request
    resp = RestClient.post(
      'https://kad.arbitr.ru/Kad/SearchInstances',
      "{'Page':1,'Count':25,'Courts':[],'DateFrom':null,'DateTo':null,'Sides':[{'Name':'#{@inn}','Type':-1,'ExactMatch':false}],'Judges':[],'CaseNumbers':[],'WithVKSInstances':false}",
      { content_type: 'application/json', cookie: "pr_fp=#{@pr_fp}; wasm=#{@wasm}" }
    )
    resp.body if resp.code == 200
  rescue Exception => e
    nil
  end
end

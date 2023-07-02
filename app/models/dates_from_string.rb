class DatesFromString
  PATTERNS = {
    [
      /\d{4}-\d{2}-\d{2}/,
      /\d{4}-\d{1}-\d{2}/,
      /\d{4}-\d{1}-\d{1}/,
      /\d{4}-\d{2}-\d{1}/,
    ] => -> string { string.to_s.split("-") },
    [
      /\d{2}-\d{2}-\d{4}/,
      /\d{2}-\d{1}-\d{4}/,
      /\d{1}-\d{1}-\d{4}/,
      /\d{1}-\d{2}-\d{4}/,
    ] => -> string { string.to_s.split("-").reverse },
    [
      /\d{4}\.\d{2}\.\d{2}/,
    ] => -> string { string.to_s.split(".") },
    [
      /\d{2}\.\d{2}\.\d{4}/,
    ] => -> string { string.to_s.split(".").reverse },
    [
      /\d{4}\/\d{2}\/\d{2}/,
    ] => -> string { string.to_s.split("/") },
    [
      /\d{2}\/\d{2}\/\d{4}/,
    ] => -> string { string.to_s.split("/").reverse },
  }

  def initialize(key_words = [])
    @key_words = key_words
  end

  def find_date(string)
    parsing_structure = ParsingStructure.new(get_structure(string))
    parsing_structure.start
  end

  def get_clear_text
    @clear_text.strip
  end

  def get_structure(string)
    if string.nil? || string.empty?
      nil
    else
      @main_arr = []
      data_arr = string.split(" ")
      @indexs = []
      @first_index = []
      @clear_text = string.clone

      data_arr.each_with_index do |data, index|
        value_year = get_year(data)
        value_full_date = get_full_date(data)
        value_month_year_date = get_month_year_date(data)
        value_dash = get_dash_data(data)
        value_month = get_month_by_list(data)
        value_short_month = get_short_month(data)
        value_time = get_time(data)

        value_day = get_day(data)
        next_index = index + 1

        if value_year
          add_to_structure(:year ,value_year, index, next_index, data_arr)
        end

        if value_full_date
          if @main_arr.size == 0
            index = 0
          end
          add_to_structure(:year ,value_full_date[0], index, next_index, data_arr)
          add_to_structure(:month ,value_full_date[1], index, next_index, data_arr)
          add_to_structure(:day ,value_full_date[2], index, next_index, data_arr)
        end

        if value_month_year_date
          add_to_structure(:year ,value_month_year_date[0], index, next_index, data_arr)
          add_to_structure(:month ,value_month_year_date[1], index, next_index, data_arr)
        end

        if value_dash
          add_to_structure(:year ,value_dash[0], index, next_index, data_arr, '-')
          add_to_structure(:year ,value_dash[1], index, next_index, data_arr)
        end

        if value_month
          add_to_structure(:month ,value_month, index, next_index, data_arr)
        end

        if value_short_month
          add_to_structure(:month ,value_short_month, index, next_index, data_arr)
        end

        if value_day
          add_to_structure(:day ,value_day, index, next_index, data_arr)
        end

        if value_time
          add_to_structure(:time ,value_time, index, next_index, data_arr)
        end

      end

      @main_arr
    end
  end

  def get_time(string)
    if (result = string.match(/\d{2}:\d{2}:\d{2}/))
      @clear_text.slice!(result.to_s)
      result.to_s
    elsif (result = string.match(/\d{2}:\d{2}/))
      @clear_text.slice!(result.to_s)
      result.to_s
    end
  end

  def get_year(string)
    case string
    when /^\d{4}$/
      string
    when /^\d{4}\.$/
      string.delete!('.')
    when /^\d{4}\,$/
      string.delete!(',')
    end
  end

  def get_full_date(string)

    PATTERNS.keys.each do |patterns|
      patterns.each do |pattern|
        if (result = string.match(pattern))
          @clear_text.slice!(result.to_s)
          return PATTERNS[patterns].call result
        end
      end
    end
    nil
  end

  def get_month_year_date(string)
    if (result = string.match(/^\d{2}\.\d{4}$/))
      result.to_s.split(".").reverse
    elsif (result = string.match(/^\d{4}\.\d{2}$/))
      result.to_s.split(".")
    end
  end

  def get_day(string)
    if string =~ (/^\d{2}$/)
      string
    end
  end


  def get_dash_data(string)
    if (result = string.match(/\d{4}-\d{4}/))
      result.to_s.split("-")
    elsif (result = string.match(/\d{4}–\d{4}/))
      result.to_s.split("–")
    end
  end

  def get_month_by_list(string)
    month = ['January','February','March','April','May','June','July','August','September','October','November','December']
    index = month.index(string)
    month = ['ЯНВАРЯ','ФЕВРАЛЯ','МАРТА','АПРЕЛЯ','МАЯ','ИЮНЯ','ИЮЛЯ','АВГУСТА','СЕНТЯБРЯ','ОКТЯБРЯ','НОЯБРЯ','ДЕКАБРЯ']
    index ||= month.index(string)
    month = ['Января','Февраля','Марта','Апреля','Мая','Июня','Июля','Августа','Сентября','Октября','Ноября','Декабря']
    index ||= month.index(string)
    month = ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря']
    index ||= month.index(string)

    if index
      sprintf('%02d',(index+1))
    end

  end

  def get_short_month(string)
    short_month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Apr','Sep','Oct','Nov','Dec']
    short_index = short_month.index(string)
    short_month = ['ЯНВ','ФЕВ','МАР','АПР','МАЯ','ИЮН','ИЮЛ','АВГ','СЕН','ОКТ','НОЯ','ДЕК']
    short_index ||= short_month.index(string)
    short_month = ['Янв','Фев','Мар','Апр','Мая','Июн','Июл','Авг','Сен','Окт','Ноя','Дек']
    short_index ||= short_month.index(string)
    short_month = ['янв','фев','мар','апр','мая','июн','июл','авг','сен','окт','ноя','дек']
    short_index ||= short_month.index(string)

    if short_index
      sprintf('%02d',(short_index+1))
    end
  end

  def add_to_structure (type ,value, index, next_index, data_arr, key_word = nil)
    set_structura
    if value
      @first_index << index
      @structura[:type] = type
      @structura[:value] = value
    end

    if value && @main_arr.last
      @main_arr.last[:distance] = calc_index(index)
    end

    if @key_words && @key_words.include?(data_arr[next_index])
      @structura[:key_words] << data_arr[next_index]
    end

    if key_word
      @structura[:key_words] << key_word
    end

    if value
      @main_arr <<  @structura
      value = nil
    end
  end

  def calc_index(index)
    result = nil
    @indexs << index
    if @indexs.count > 1
      result = (index - @indexs[-2])
    elsif @first_index[0] < index
      result = (index - @first_index[0])
    else
      result = index
    end
  end

  def set_structura
    @structura = {type: nil, value: nil, distance: 0, key_words: []}
  end
end

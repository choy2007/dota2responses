module Responses
  class Dota2GamepediaConnector
    Dota2GamepediaConnectorResult = ImmutableStruct.new(:body, :status, :success?, :errors)
    
    # Some actions are from https://github.com/Jonarzz/DotaResponsesRedditBot
    BASE_PATH = 'https://dota2.gamepedia.com'  
    API_PATH = BASE_PATH + '/api.php'
    CATEGORY_API_PARAMS = {'action': 'query', 'list': 'categorymembers', 'cmlimit': 'max', 'cmprop': 'title',
                           'format': 'json', 'cmtitle': ''}
    RESPONSE_REGEX = /([a-z0-9_\.-\[\]\'\!\-\%\u0401\u0451\u0410-\u044f\u4E00-\uFA29\uE7C7-\uE7F3\uAC00-\uD7A3]+)/i
    
    def initialize
      @connection = create_connection
    end
    
    def create_heroes_and_responses
      populate_hero_responses
      populate_chat_wheel
    end
    
    def populate_hero_responses
      pages = pages_for_category('Responses')
      pages.each do |page|
        if is_hero?(page)
          # Response is from hero
          hero_name = get_hero_name(page)
        else
          # Response is from voice pack/announcer/others
          next
        end
        @connection.url = "#{BASE_PATH}/#{hero_name}/Responses?action=raw"
        @connection.http_get
         
        if @connection.response_code == 200
          response_source = @connection.body_str
          hero_responses = create_responses_list(response_source)
          
          hero = Hero.new(name: parse_hero_name(hero_name))
          if hero.save
            puts "#{hero.name} has been created!"
            hero_responses.each do |response|
              next if response.empty?
              
              response = Response.new(title: response, hero: hero)
              puts "#{hero.name}: #{response.title}" if response.save
            end
          end
        else
          get_error_connection_result
        end
      end
    end
    
    def populate_chat_wheel
      @connection.url = "#{BASE_PATH}/Chat_Wheel"
      @connection.http_get
      
      if @connection.response_code == 200
        chat_wheel_source = @connection.body_str
        chat_wheel = create_chat_wheel_list(chat_wheel_source)
        
        chat_wheel.each do |chat_wheel_list|
          event_name = chat_wheel_list[0]
          
          event = Event.new(name: event_name)
          if event.save
            puts "#{event.name} has been created"
            chat_wheel_list.each_with_index do |response, index|
              next if index.eql?(0)
              
              response = Response.new(title: response, event: event)
              puts "#{response.title}" if response.save
            end
          end
        end
      end
    end
    
    private
    
    def create_connection
      Curl::Easy.new do |curl|
        curl.headers['Content-Type'] = 'application/json'
      end
    end
    
    def pages_for_category(category_name)
      pages = []
      params = get_params_for_category_api(category_name)
      @connection.url = "#{API_PATH}?#{params}"
      @connection.http_get
      
      if @connection.response_code == 200
        response = get_successful_connection_result 
        response.body['query']['categorymembers'].each do |category_member|
          title = category_member['title']
          pages.push(title)
        end
      else
        get_error_connection_result
      end
      pages = exclude_heroes(pages)
    end
    
    def get_params_for_category_api(category)
      params = CATEGORY_API_PARAMS
      params[:cmtitle] = 'Category:' + category
      params.to_query
    end
    
    def create_responses_list(responses_source)
      responses_list = []
      
      responses_html = Nokogiri::HTML(responses_source)

      responses = responses_html.search('p')[0].children.map(&:text).first(15)
      responses = responses.reject {|phrase| phrase.empty? || phrase.include?('mp3') || phrase.include?('==') || phrase.include?('Tabs Hero')}
      
      responses.each do |response|
        responses_list.push(parse_response(response))
      end
      responses_list
    end
    
    def create_chat_wheel_list(chat_wheel_source)
      chat_wheel_list = []
      
      chat_wheel_html = Nokogiri::HTML(chat_wheel_source)
      
      the_internationals = chat_wheel_html.xpath('//p//a[starts-with(text(), "The International")]')
      
      the_internationals.each_with_index do |ti, index|
        ti_event = ti.child.text
        ti_chat_wheel = ti.parent.next_element.children[1].xpath('//td//ul//li/text()')
        
        chat_wheel = chat_wheel_html.xpath('//p//a[starts-with(text(), "The International")]')[index].parent.next_element.children[1].xpath('.//td//ul//li/text()')
        chat_wheel_span = chat_wheel_html.xpath('//p//a[starts-with(text(), "The International")]')[index].parent.next_element.children[1].xpath('.//td//ul//li//span/text()')
        chat_wheel = chat_wheel + chat_wheel_span
        
        chat_wheel_list.push([ti_event])
        
        chat_wheel.each do |response|
          chat_wheel_text = response.content.strip
          next if parse_response(chat_wheel_text).empty? || parse_response(chat_wheel_text).eql?('[All]')
          
          chat_wheel_list[index].push(parse_response(chat_wheel_text))
        end
      end
      chat_wheel_list
    end
    
    def get_hero_name(hero_page)
      hero_page.split('/')[0].gsub(' ', '_')
    end
    
    def parse_hero_name(hero_name)
      hero_name.gsub('_', ' ')
    end
    
    def is_hero?(page)
      return true if page.include? '/Responses'
      false
    end
    
    def exclude_heroes(pages)
      # Exclude heroes that return wrong responses for the meantime
      pages.reject {|page|
        page.eql?('Dark Willow/Responses')    ||
        page.eql?('Monkey King/Responses')    ||
        page.eql?('Phoenix/Responses')        ||
        page.eql?('Skeletong King/Responses') ||
        page.eql?('Io/Responses')             ||
        page.eql?('Juggernaut/Responses')     ||
        page.eql?('Pangolier/Responses')      ||
        page.eql?('Rubick/Responses')         ||
        page.eql?('Terrorblade/Responses')    ||
        page.eql?('Tiny/Responses')           ||
        page.eql?('Zeus/Responses') 
      }
    end
    
    def parse_response(response)
      response.scan(RESPONSE_REGEX).flatten.join(' ').gsub('resp u', '')
    end
    
    def get_successful_connection_result
      Dota2GamepediaConnectorResult.new(body: JSON.parse(@connection.body_str), status: @connection.response_code, success: true)
    end

    def get_error_connection_result
      Dota2GamepediaConnectorResult.new(status: @connection.response_code, errors: true)
    end
  end
end
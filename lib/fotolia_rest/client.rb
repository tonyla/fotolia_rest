require 'net/http'
require 'uri'
require 'cgi'
require 'json'
module FotoliaRest
  class Client

    BASE_URL = 'api.fotolia.com'
    attr_reader :api_key, :username, :password, :session_id
    def initialize(api_key, username, password)
      @api_key = api_key
      @username = username
      @password = password
      @session_id = nil
      @logger = defined?(Rails) ? Rails.logger : nil
    end

    def log(level, message)
      if @logger
        @logger.send(level.to_sym, message)
      end
    end

    def login
      result = execute('user', 'loginUser', {:login => username, :pass => password}, :post)
      @session_id = result.response['session_token'] if result.success?
      return result
    end

    def logged_in?
      @session_id && @session_id != ''
    end

    def execute(method, function, args={}, http_method=:get)
      begin
        uri = URI.parse(compose_uri(method, function))
        http = Net::HTTP.new(uri.host, uri.port)
        if http_method == :get
          uri.query = URI.encode_www_form(fotolia_parameters(args))
          request = Net::HTTP::Get.new(uri.request_uri)
          request.basic_auth api_key, @session_id
          request['session_id'] = @session_id if logged_in?
          response = http.request(request)
        else
          request = Net::HTTP::Post.new(uri.request_uri)
          request.basic_auth api_key, @session_id
          request.set_form_data(args)
          request['session_id'] = @session_id if logged_in?
          response = http.request(request)
        end
        Result.parse(response)
      rescue Timeout::Error => e
        log(:error, "Timeout error with #{method} #{args.inspect}")
        raise FotoliaError.new("Fotolia Communication Error: timeout")
      rescue => e
        log(:error, "Fotolia client error with #{method} #{args.inspect} #{e.message}")
        e.backtrace.each{|line| log(:debug, line)}
        raise FotoliaError.new("Fotolia Communication Error: #{e.message}")
      end
    end

    protected

    def fotolia_parameters(args)
      normalized = {}
      args.each do |key, value|
        if value.is_a?(Hash)
          value.each do |inner_key, inner_value|
            normalized["#{key}[#{inner_key}]"] = inner_value
          end
        else
          normalized[key] = value
        end
      end
      normalized
    end

    def compose_uri(method, function)
      "http://#{BASE_URL}/Rest/1/#{method}/#{function}"
    end

  end
end

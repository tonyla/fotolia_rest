require 'net/http'
require 'uri'
require 'cgi'
require 'json'
module FotoliaRest
  class Client

    BASE_URL = 'api.fotolia.com'
    attr_reader :api_key, :username, :password
    def initialize(api_key, username, password)
      @api_key = api_key
      @username = username
      @password = password
    end

    def execute(method, function, args, http_method=:get)
      uri = URI.parse(compose_uri(method, function))
      http = Net::HTTP.new(uri.host, uri.port)
      if http_method == :get
        uri.query = URI.encode_www_form(fotolia_parameters(args))
        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth api_key, nil
        response = http.request(request)
      else

      end
      Result.parse(response)
    end

    protected

    def fotolia_parameters(args)
      normalized = {}
      args.each do |key, value|
        if value.is_a?(Hash)
          value.each do |inner_key, inner_value|
            normalized["#{key}[#{inner_key}]"] = inner_value
          end
        end
      end
      normalized
    end

    def compose_uri(method, function)
      "http://#{api_key}@#{BASE_URL}/Rest/1/#{method}/#{function}"
    end

  end
end

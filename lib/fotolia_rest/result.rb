require 'json'

module FotoliaRest
  class Result
    attr_reader :response, :error

    def initialize(code, body)
      @response = JSON.parse(body)
      case code.to_s
      when "200"
        @success = true
      else
        @success = false
        @error = FotoliaApiError.new(@response['code'], @response['error'])
      end
    end

    def success?
      @success
    end

    class << self
      def parse(response)
        self.new(response.code, response.body)
      end
    end

  end
end

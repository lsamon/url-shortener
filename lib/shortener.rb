# frozen_string_literal: true

require 'tiny_url'

# URL shortener wrapper
class Shortener
  class << self
    attr_writer :backend

    delegate :shorten, to: :backend

    def backend
      @backend ||= BitlyBackend.new
    end
  end

  # bitly interface
  class BitlyBackend
    def initialize(token: Rails.application.credentials.bitly_access_token)
      @client = Bitly::API::Client.new(token: token)
    end

    def shorten(long_url)
      @client.shorten(long_url: long_url).link
    end
  end

  # tinyurl interface
  class TinyUrlBackend
    def initialize(token: Rails.application.credentials.tinyurl_access_token)
      @client = TinyUrl.new(token: token)
    end

    def shorten(long_url)
      @client.shorten(long_url)
    end
  end

  # Do not shorten
  class NoOpBackend
    def shorten(url)
      url
    end
  end
end

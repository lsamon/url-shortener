# frozen_string_literal: true

# shorten url using Tinyurl service
class TinyUrl
  include HTTParty

  class Unauthorized < StandardError; end
  class NotImplemented < StandardError; end
  class UnprocessableEntity < StandardError; end
  class MethodNotAllowed < StandardError; end
  class ServerError < StandardError; end

  ERRORS = {
    1 => Unauthorized,
    2 => NotImplemented,
    4 => MethodNotAllowed,
    5 => UnprocessableEntity,
    7 => ServerError
  }.freeze

  base_uri 'https://api.tinyurl.com'

  def self.shorten(long_url)
    instance.shorten(long_url)
  end

  def self.instance
    @instance || new
  end

  def initialize(token: Rails.application.credentials.tinyurl_access_token)
    @token = token
  end

  def shorten(long_url)
    @response = self.class.post(
      '/create',
      body: { url: long_url },
      headers: { 'Authorization' => "Bearer #{token}" }
    )

    validate_response!

    @response.dig('data', 'tiny_url')
  end

  private

  attr_reader :token, :instance

  def validate_response!
    code = @response['code']
    return if code.zero?

    error = ERRORS.fetch(code)
    raise error, @response['errors'].to_sentence if error.present?
  end

  def allowed_error_codes
    ERRORS.keys
  end
end

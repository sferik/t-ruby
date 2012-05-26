module T
  module Authorizable

    DEFAULT_HOST = 'api.twitter.com'
    DEFAULT_PROTOCOL = 'https'

  private

    def base_url
      "#{protocol}://#{host}"
    end

    def generate_authorize_url(consumer, request_token)
      request = consumer.create_signed_request(:get, consumer.authorize_path, request_token, pin_auth_parameters)
      params = request['Authorization'].sub(/^OAuth\s+/, '').split(/,\s+/).map do |param|
        key, value = param.split('=')
        value =~ /"(.*?)"/
        "#{key}=#{CGI::escape($1)}"
      end.join('&')
      "#{base_url}#{request.path}?#{params}"
    end

    def pin_auth_parameters
      {:oauth_callback => 'oob'}
    end

  end
end

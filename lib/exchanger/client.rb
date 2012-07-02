module Exchanger
  # SOAP Client for Exhange Web Services
  class Client
    delegate :endpoint, :timeout, :username, :password, :debug, :insecure_ssl, :to => "Exchanger.config"

    def initialize
      uri = URI.parse(endpoint)
      @client = Net::HTTP.new(uri.host, uri.port)
      @client.use_ssl = true
      @client.set_debug_output $stderr if debug
    end

    # Does the actual HTTP level interaction.
    def request(post_body, headers)
      uri = URI.parse(endpoint)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = post_body
      headers.each do |key, value|
        request[key] = value
      end
      request.ntlm_auth(username, get_domain(uri.host), password)
      response = @client.request(request)

      { :status => response.code, :body => response.body, :content_type => response['content-type'] }
    end

    private
    # from http://stackoverflow.com/a/983558/62
    def get_domain(host)
      re = /^(?:(?>[a-z0-9-]*\.)+?|)([a-z0-9-]+\.(?>[a-z]*(?>\.[a-z]{2})?))$/i
      host.gsub(re, '\1').strip
    end
  end
end

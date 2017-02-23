require 'api_callers/json_request'
require 'api_callers/http_requester'

class MeetupApi
  DIRECT_BASE_URL = 'https://api.meetup.com'
  METHOD_BASE_URL = 'https://api.meetup.com/2/'

  def initialize(include_code = false)
    @include_code = include_code
  end

  def direct_request(request_type, method_uri, params)
    request(DIRECT_BASE_URL + method_uri, params, request_type)
  end

  def method_request(method, params)
    request(METHOD_BASE_URL + method.to_s, params)
  end

  def multipart_post(method_uri, files, params)
    request(DIRECT_BASE_URL + method_uri, params, :post, files)
  end

  def method_missing(method, *args, &block)
    if method =~ /^(get|post|put|patch|delete)$/
      self.direct_request(method, args[0], args[1])
    else
      self.method_request(method, args[0])
    end
  end

  private

  def request(url_base, params, request_type = :get, multipart_files = nil)
    params = params.merge( { key: ::MeetupClient.config.api_key } )
    url = "#{url_base}?#{query_string(params)}"

    json_request = ApiCallers::JsonRequest.new(url, request_type, multipart_files, @include_code)
    requester = ApiCallers::HttpRequester.new(json_request)
    requester.execute_request
  end

  def query_string(params)
    params.map { |k,v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}" }.join("&")
  end
end

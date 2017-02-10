require 'net/http/post/multipart'

module ApiCallers
  class HttpRequest
    CHARSET = 'UTF-8'

    def initialize(uri, method = 'get', files = nil, with_code = false)
      @in_uri = uri
      @method = method
      @multipart_files = files
      @with_code = with_code
    end

    def make_request
      uri = URI.parse(@in_uri)
      request = if @multipart_files
        Net::HTTP::Post::Multipart.new(
            uri.request_uri,
            @multipart_files.update(@multipart_files){|k,v| UploadIO.new(*v)},
            headers)
      else
        class_to_call.new(uri.request_uri, headers)
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request(request)
      formatted = format_response(response.body)
      @with_code ? [formatted, response.code] : formatted
    end

    def format_response(response_body); response_body; end;

    private

    def headers
      { 'Accept-Charset' => CHARSET }
    end

    def class_to_call
      Net::HTTP.const_get(@method.capitalize)
    end

  end
end

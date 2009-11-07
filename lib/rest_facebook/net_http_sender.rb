require 'digest/md5'

module RestFacebook
  
  class NetHttpSender
    
    def post_form( params)
      response = Net::HTTP.post_form post_url, post_for( params)
      response = RestFacebook.dyno_json_decode( response.body)
      raise_exception_if_error response
    end
    
    
    private
      def post_url
        URI.parse 'http://' + RestFacebook::API_HOST + RestFacebook::API_PATH_REST
      end
      
      def post_for( params)
        post_params = {}
        params.each do |k,v|
          k = k.to_s unless k.is_a?(String)
          if Array === v || Hash === v
            post_params[k] = RestFacebook.dyno_json_encode( v)
          else
            post_params[k] = v
          end
        end
        post_params
      end
      
      def raise_exception_if_error response
        if Hash === response and response.include? "error_msg"
          request_str = "for request: "
          response[ 'request_args'].reverse.map{|h| request_str << " #{h[ 'key']}='#{h[ 'value']}'" }
          error_str = "#{response[ "error_msg"]} #{request_str}"
          raise RemoteStandardError.new( error_str, response[ "error_code"])
        end

        response
      end
  end
  
end
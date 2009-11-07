require 'digest/md5'

module RestFacebook
  
  # basic error classes
  class RemoteStandardError < StandardError
    def initialize(message, code)
      @error_msg = "(#{code}) #{message}"
    end
    def to_s
      @error_msg
    end
  end
  
  class ExpiredSessionStandardError < RemoteStandardError; end
  class NotActivatedStandardError < StandardError; end
  
  class Session
  
  
    # properties
    attr_reader :uid, :session_key, :expires, :secret_from_session
  
    # Constructs a FbSession
    #
    # api_key::     your API key
    # api_secret::  your API secret
    # quiet::       boolean, set to true if you don't want exceptions to be thrown (defaults to false)
    def initialize(api_key, api_secret)
      # required parameters
      @api_key = api_key
      @api_secret = api_secret

      @sender = NetHttpSender.new
    end
    
    def init_session_state params
      s_params  = params.symbolize_keys!
      
      @session_key         = s_params[ :session_key]
      @uid                 = s_params[ :uid]
      @expires             = s_params[ :expires]
      @secret_from_session = s_params[ :secret_from_session]
      
      self
    end
    
    def dump_session_state
      {:uid=> uid, :session_key=> session_key, :expires=> expires, :secret_from_session=> secret_from_session}
    end
    
    def call(method, params={}, use_session_key=true)
      to_fb_params(method, params)
      use_session_key && @session_key && params[:session_key] ||= @session_key
      final_params = params.merge(:sig => signature(params))

      @sender.post_form( final_params)
    end
    
    def map_call(method, params={}, use_session_key=true)
      ResponseMapper.map( method, call( method, params, use_session_key))
    end
    
    
    private
    
      def to_fb_params(method, hash)
        hash[:method] = "facebook.#{method}"
        hash[:api_key] = @api_key
        hash[:call_id] = Time.now.to_f.to_s unless method == 'auth.getSession'
        hash[:v] = "1.0"
        hash[:format] = "JSON"
      end
      
      def signature(params)
        raw_string = params.inject([]) do |collection, pair|
          collection << pair.map { |x|
            Array === x ? RestFacebook.dyno_json_encode(x) : x
          }.join("=")
          collection
        end.sort.join
        Digest::MD5.hexdigest( [raw_string, @api_secret].join)
      end
      
    
  end
  
end
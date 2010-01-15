module RestFacebook
  
  VERSION                   = "draft"

  API_VERSION               = "1.0"

  API_HOST                  = "api.facebook.com"
  API_PATH_REST             = "/restserver.php"
  
  
  def self.yml
    @facebook_apps
  end

  def self.load_app_config yaml_file
    raise StandardError.new ("Can't find configuration file") unless File.exists? yaml_file
    
    yaml = YAML.load( ERB.new( File.read( yaml_file)).result)
    yaml = yaml[RAILS_ENV] if defined? RAILS_ENV
    
    raise StandardError.new("rest_facebook.yml: Can't find properties for '#{RAILS_ENV}' environment") unless yaml
    raise StandardError.new("rest_facebook.yml: Can't find required properties") unless check_app_config yaml
    
    RAILS_DEFAULT_LOGGER.info("** REST Facebook is configured")
    
    @facebook_apps = yaml
  end
  
  def self.new_fb_session
    RestFacebook::Session.new( @api_key, @secret_key)
  end
  
  def self.get_auth_fb_session( auth, ss=false)
    s = new_fb_session
    credential = s.call('auth.getSession', {:auth_token=> auth, :generate_session_secret => ss})

    s.init_session_state credential
    s
  end
  
  def self.load_fb_session_from( cookies)
    parsed = {}
    fb_cookie_prefix = @api_key+'_'
    fb_cookie_names = cookies.keys.select{ |k| k && k.starts_with?( fb_cookie_prefix)}
    fb_cookie_names.each { |key| parsed[ key[ fb_cookie_prefix.size,key.size]] = cookies[ key] }
    
    #returning gracefully if the cookies aren't set or have expired
    return unless parsed['session_key'] && parsed['user'] && parsed['expires'] && parsed['ss'] 
    return unless Time.at(parsed['expires'].to_s.to_f) > Time.now || (parsed['expires'] == "0")
    
    # unify params name
    parsed['uid'] = parsed[ 'user'] and parsed['secret_from_session'] = parsed[ 'ss']
    
    s = new_fb_session
    s.init_session_state parsed
    s
  end
  
  private
  
    def self.check_app_config yaml
      (@api_key = yaml[ 'api_key'] if yaml[ 'api_key']) and (@secret_key = yaml[ 'secret_key'] if yaml[ 'secret_key'])
    end
  
end

require 'passive_resource'
if defined?( PassiveResource::Backports::JSON.decode) and defined?( PassiveResource::Backports::JSON.encode)
  module RestFacebook
    def self.dyno_json_encode(hash) PassiveResource::Backports::JSON.encode( hash); end
    def self.dyno_json_decode(str)  PassiveResource::Backports::JSON.decode( str); end
  end
end


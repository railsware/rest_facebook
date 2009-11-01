module RestFacebook::Connect
  
  API_VERSION               = "1.0"

  API_HOST                  = "api.facebook.com"
  API_PATH_REST             = "/restserver.php"

  APP_API_KEY               = "4e4354693b7a6305d3e8bb616d8ebfe4"
  APP_SECRET_KEY            = "c433722b5d4659e954a0e1d340819fac"
  
  
  def self.new_fb_session
    RestFacebook::Session.new( APP_API_KEY, APP_SECRET_KEY)
  end
  
  def self.get_auth_fb_session( auth, ss=false)
    s = new_fb_session
    credential = s.call('auth.getSession', {:auth_token=> auth, :generate_session_secret => ss})

    s.init_session_state credential
    s
  end
  
  def self.load_fb_session_from( cookies)
    parsed = {}
    fb_cookie_prefix = APP_API_KEY+'_'
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
  
end
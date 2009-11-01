module RestFacebook::ConnectHelper
  
  
  def fb_connect_javascript_tag(options={})
    lang = "/#{options[:lang].to_s.gsub('-', '_')}" if options[:lang]
    "<script src=\"http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php#{lang}\" type=\"text/javascript\"></script>"
  end
  
  def init_fb_connect_js(*required_features)

    init_string = "FB.init('#{RestFacebook::Connect::APP_API_KEY}','/xd_receiver.html', {});"
    
    unless required_features.blank?
       init_string = <<-FBML
          $(document).ready(
            function() {
              FB_RequireFeatures(#{required_features.to_json}, function() {
                #{init_string}
              }
          );
       FBML
    end

    javascript_tag init_string
  end
  
  def fb_connect_button(*args)

    callback = args.first
    options = args[1] || {}
    options.merge!(:onlogin=>callback)if callback

    content_tag("fb:login-button",nil, options)
  end
  
  VALID_PERMISSIONS=[:email, :offline_access, :status_update, :photo_upload, :create_listing, :create_event, :rsvp_event, :sms, :video_upload, :publish_stream, :read_stream]
  
  def fb_prompt_permission(permission,message,callback=nil)
    raise(ArgumentError, "Unknown value for permission: #{permission}") unless VALID_PERMISSIONS.include?(permission.to_sym)
    args={:perms=>permission}
    args[:next_fbjs]=callback unless callback.nil?
    content_tag("fb:prompt-permission",message,args)
  end
  
end
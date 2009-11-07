require 'rest_facebook'
require 'rest_facebook/connect_helper'
require 'rest_facebook/session'
require 'rest_facebook/acts_with_fb_connect'

RestFacebook.load_app_config( "#{RAILS_ROOT}/config/rest_facebook.yml")

ActionController::Base.send :include, RestFacebook::ActsWithFbConnect
ActionView::Base.send :include, RestFacebook::ConnectHelper
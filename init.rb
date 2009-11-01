require 'rest_facebook/acts_with_fb_connect'
require 'rest_facebook/connect'
require 'rest_facebook/connect_helper'
require 'rest_facebook/session'

ActionController::Base.send :include, RestFacebook::ActsWithFbConnect
ActionView::Base.send :include, RestFacebook::ConnectHelper
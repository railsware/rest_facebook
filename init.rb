ActionController::Base.send :include, RestFacebook::ActsWithFbConnect
ActionView::Base.send :include, RestFacebook::ConnectHelper
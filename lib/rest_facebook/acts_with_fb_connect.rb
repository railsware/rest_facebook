module RestFacebook::ActsWithFbConnect
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def acts_with_fb_connect
      class_eval <<-EOV
        include RestFacebook::ActsWithFbConnect::InstanceMethods
        before_filter :lookup_fb_session
      EOV
    end
  end
  
  module InstanceMethods
    
    private
      def lookup_fb_session
          @fb_session = RestFacebook.load_fb_session_from cookies
      end
    
  end
end
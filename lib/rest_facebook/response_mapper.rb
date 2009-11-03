module RestFacebook::ResponseMapper
  
  METHODS = {
    "users.hasAppPermission" => lambda{ |r| r == 1 }
  }
  
  def self.map( method, response)
    proc = METHODS[ method]
    proc ? proc.call( response) : response
  end
end
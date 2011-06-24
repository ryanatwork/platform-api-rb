require 'savon'
require 'hashie'

module GranicusPlatformAPI
  class Client
    # create a connected client
    def initialize(granicus_site,username,password,options={})
      # set things up
      @granicus_site = granicus_site
      Savon.configure do |config|
        config.log = false
      end
      HTTPI.log = false
      
      # create the client
      @client = Savon::Client.new do |wsdl, http|
        wsdl.document = File.expand_path("../granicus-platform-api.xml", __FILE__)
        wsdl.endpoint = "http://#{granicus_site}/SDK/User/index.php" 
        http.proxy = "http://localhost:8888"
      end
      
      # call login
      @client.request :wsdl, :login do
        soap.body = { :username => username, :password => password }
      end
    end
    
    # return the current logged on user name
    def get_current_user_logon
      response = @client.request :wsdl, :get_current_user_logon
      response.to_hash[:get_current_user_logon_response][:logon]
    end
    
    # return all of the cameras
    def get_cameras
      response = @client.request :wsdl, :get_cameras
      scrub_response response.to_hash[:get_cameras_response][:cameras]
    end

    # return all of the folders
    def get_folders
      response = @client.request :wsdl, :get_folders
      scrub_response response.to_hash[:get_folders_response][:folders]
    end
    
    # return all of the clips
    def get_clips(folder_id)
      response = @client.request :wsdl, :get_clips do
        soap.body = { :folder_id => folder_id, :attributes! => {:folder_id => {"xsi:type" => "xsd:int"}} }
      end
      puts response.to_xml
      response.to_hash[:get_clips_response][:clips]
    end
    
    def get_servers
      response = @client.request :wsdl, :get_servers
    end
    
    private
    
    def scrub_response(response)
      hashie = Hashie::Mash.new response
      (hashie.item.is_a? Array) ? hashie.item : [ hashie.item ]
    end
  end
end
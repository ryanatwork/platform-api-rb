require 'savon'
require 'hashie'
require 'multi_xml'

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
      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns4:GetCurrentUserLogonResponse/Logon', doc.root.namespaces)[0]
    end

    # logout
    def logout
      response = @client.request :wsdl, :logout
      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns4:LogoutResponse', doc.root.namespaces)[0]
    end

    # return all of the cameras
    def get_cameras
      response = @client.request :wsdl, :get_cameras

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetCamerasResponse/cameras', doc.root.namespaces)[0]
    end
    
    # return the requested event
    def get_camera(camera_id)
      response = @client.request :wsdl, :get_camera do
        soap.body = { :camera_id => camera_id, :attributes! => {:camera_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetCameraResponse/camera', doc.root.namespaces)[0]
    end

    # return all of the events
    def get_events
      response = @client.request :wsdl, :get_events

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetEventsResponse/events', doc.root.namespaces)[0]
    end
    
    # return all of the events with matching foreign id
    def get_events_by_foreign_id(foreign_id)
      response = @client.request :wsdl, :get_events_by_foreign_id do
        soap.body = { :foreign_id => foreign_id, :attributes! => {:foreign_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetEventsByForeignIDResponse/events', doc.root.namespaces)[0]
    end
    
    # return the requested event
    def get_event(event_id)
      response = @client.request :wsdl, :get_event do
        soap.body = { :event_id => event_id, :attributes! => {:event_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetEventResponse/event', doc.root.namespaces)[0]
    end

    # return all of the event meta data
    def get_event_meta_data(event_id)
      response = @client.request :wsdl, :get_event_meta_data do
        soap.body = { :event_id => event_id, :attributes! => {:event_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetEventMetaDataResponse/metadata', doc.root.namespaces)[0]
    end
    
    # set the event agenda url
    def set_event_agenda_url(event_id,url)
      response = @client.request :wsdl, :set_event_agenda_url do
        soap.body = { :event_id => event_id, 
                      :url => url, 
                      :attributes! => {:event_id => {"xsi:type" => "xsd:int"}, :url => {"xsi:type" => "xsd:string"}} }
      end
      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns4:SetEventAgendaURLResponse', doc.root.namespaces)[0]
    end
    
    # return all of the clip meta data
    def get_clip_meta_data(clip_id)
      response = @client.request :wsdl, :get_clip_meta_data do
        soap.body = { :clip_id => clip_id, :attributes! => {:clip_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetClipMetaDataResponse/metadata', doc.root.namespaces)[0]
    end

    # return all of the folders
    def get_folders
      response = @client.request :wsdl, :get_folders

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetFoldersResponse/folders', doc.root.namespaces)[0]
    end

    # return all of the clips
    def get_clips(folder_id)
      response = @client.request :wsdl, :get_clips do
        soap.body = { :folder_id => folder_id, :attributes! => {:folder_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetClipsResponse/clips', doc.root.namespaces)[0]
    end
    
    # return all of the clips with matching foreign id
    def get_clips_by_foreign_id(foreign_id)
      response = @client.request :wsdl, :get_clips_by_foreign_id do
        soap.body = { :foreign_id => foreign_id, :attributes! => {:foreign_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetClipsByForeignIDResponse/clips', doc.root.namespaces)[0]
    end
    
    # return the requested clip
    def get_clip(clip_id)
      response = @client.request :wsdl, :get_clip do
        soap.body = { :clip_id => clip_id, :attributes! => {:clip_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetClipResponse/clip', doc.root.namespaces)[0]
    end
    
    # return the requested clip
    def get_clip_by_uid(clip_uid)
      response = @client.request :wsdl, :get_clip_by_uid do
        soap.body = { :clip_uid => clip_uid, :attributes! => {:clip_uid => {"xsi:type" => "xsd:string"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetClipByUIDResponse/clip', doc.root.namespaces)[0]
    end

    # get servers
    def get_servers
      response = @client.request :wsdl, :get_servers
      
      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetServersResponse/servers', doc.root.namespaces)[0]
    end
    
    # return the requested server
    def get_server(server_id)
      response = @client.request :wsdl, :get_server do
        soap.body = { :server_id => server_id, :attributes! => {:server_id => {"xsi:type" => "xsd:int"}} }
      end

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetServerResponse/server', doc.root.namespaces)[0]
    end

    private

    def typecast_value_node(node, parent=nil)
      if node.is_a? Nokogiri::XML::NodeSet or node.is_a? Array then
        return node.map {|el| typecast_value_node el } 
      end
      return node.to_s unless node['type'] 
      typespace,type = node['type'].split(':')
      case typespace
      when 'xsd'
        proc = self.class.typecasts[type]
        unless proc.nil?
          proc.call(node.children[0].to_s)
        else
          puts "Unknown xsd:type: #{type}"
          node.children[0].to_s
        end
      when 'SOAP-ENC'
        if type == 'Array' then
          node.children.map {|element| typecast_value_node element }
        else
          puts "Unknown SOAP-ENC:type: #{type}"
          node.to_s
        end
      else
        # we have a custom type, make it hashie since we don't want true static typing
        value = ::Hashie::Mash.new
        node.children.each do |value_node|
          value[value_node.name.snakecase] = typecast_value_node value_node, value
        end
        # add the type of the complex type to the parent as 'nodename_object_type', this is for handling metadata
        parent[node.name.snakecase + '_object_type'] = type.snakecase unless parent.nil?
        value
      end
    end
    
    # typecasts ripped from rubiii/nori, adapted for xsd types
    def self.typecasts
      @@typecasts
    end

    def self.typecasts=(obj)
      @@typecasts = obj
    end

    def self.available_typecasts
      @@available_typecasts
    end

    def self.available_typecasts=(obj)
      @@available_typecasts = obj
    end

    self.typecasts = {}
    self.typecasts["int"] = lambda { |v| v.nil? ? nil : v.to_i }
    self.typecasts["boolean"] = lambda { |v| v.nil? ? nil : (v.strip != "false") }
    self.typecasts["datetime"] = lambda { |v| v.nil? ? nil : Time.parse(v).utc }
    self.typecasts["date"] = lambda { |v| v.nil? ? nil : Date.parse(v) }
    self.typecasts["dateTime"] = lambda { |v| v.nil? ? nil : Time.parse(v).utc }
    self.typecasts["decimal"] = lambda { |v| v.nil? ? nil : BigDecimal(v.to_s) }
    self.typecasts["double"] = lambda { |v| v.nil? ? nil : v.to_f }
    self.typecasts["float"] = lambda { |v| v.nil? ? nil : v.to_f }
    self.typecasts["symbol"] = lambda { |v| v.nil? ? nil : v.to_sym }
    self.typecasts["string"] = lambda { |v| v.to_s }
    self.typecasts["yaml"] = lambda { |v| v.nil? ? nil : YAML.load(v) }
    self.typecasts["base64Binary"] = lambda { |v| v.unpack('m').first }

    self.available_typecasts = self.typecasts.keys
    
  end
end
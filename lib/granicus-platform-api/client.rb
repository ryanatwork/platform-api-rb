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

    # return all of the events
    def get_events
      response = @client.request :wsdl, :get_events

      doc = Nokogiri::XML(response.to_xml) do |config|
        config.noblanks
      end
      typecast_value_node doc.xpath('//ns5:GetEventsResponse/events', doc.root.namespaces)[0]
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

    def get_servers
      response = @client.request :wsdl, :get_servers
    end

    private

    def typecast_value_node(node)
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
          value[value_node.name.snakecase] = typecast_value_node value_node
        end
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
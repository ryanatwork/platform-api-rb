require 'savon'

module GranicusPlatformAPI
  class Client
    
    # mappings between soap types and our complex types
    # this area should be rewritten to auto-generate data sets properly
    # and refactored to separate standard xsd types from custom types in class 
    # map
    def self.typegenerators
      @@typegenerators
    end

    def self.typegenerators=(obj)
      @@typegenerators = obj
    end

    self.typegenerators = {}
    
    self.typegenerators["AgendaItem"] = lambda { AgendaItem.new }
    self.typegenerators["Attendee"] = lambda { Attendee.new }
    self.typegenerators["AttendeeStatus"] = lambda { AttendeeStatus.new }
    self.typegenerators["CameraData"] = lambda { CameraData.new }
    self.typegenerators["CaptionData"] = lambda { CaptionData.new }
    self.typegenerators["ClipData"] = lambda { ClipData.new }
    self.typegenerators["Document"] = lambda { Document.new }
    self.typegenerators["EventData"] = lambda { EventData.new }
    self.typegenerators["FolderData"] = lambda { FolderData.new }
    self.typegenerators["GroupData"] = lambda { GroupData.new }
    self.typegenerators["KeyMapping"] = lambda { KeyMapping.new }
    self.typegenerators["MetaDataData"] = lambda { MetaDataData.new }
    self.typegenerators["Motion"] = lambda { Motion.new }
    self.typegenerators["Note"] = lambda { Note.new }
    self.typegenerators["Rollcall"] = lambda { Rollcall.new }
    self.typegenerators["ServerData"] = lambda { ServerData.new }
    self.typegenerators["ServerInterfaceData"] = lambda { ServerInterfaceData.new }
    self.typegenerators["TemplateData"] = lambda { TemplateData.new }
    self.typegenerators["ViewData"] = lambda { ViewData.new }
    self.typegenerators["VoteEntry"] = lambda { VoteEntry.new }
    self.typegenerators["VoteRecord"] = lambda { VoteRecord.new }
    
    # classmap for generating proper attributes! hash within savon calls
    def self.classmap
      @@classmap
    end

    def self.classmap=(obj)
      @@classmap = obj
    end

    # built-in types
    self.classmap = {}
    self.classmap['Fixnum'] = "xsd:int"
    self.classmap['String'] = "xsd:string"
    self.classmap['TrueClass'] = 'xsd:boolean'
    self.classmap['FalseClass'] = 'xsd:boolean'
    self.classmap['Time'] = 'xsd:dateTime'
    
    # start custom types
    self.classmap['AgendaItem'] = 'granicus:AgendaItem'
    self.classmap['Attendee'] = 'granicus:Attendee'
    self.classmap['AttendeeStatus'] = 'granicus:AttendeeStatus'
    self.classmap['CameraData'] = 'granicus:CameraData'
    self.classmap['CaptionData'] = 'granicus:CaptionData'
    self.classmap['ClipData'] = 'granicus:ClipData'
    self.classmap['Document'] = 'granicus:Document'
    self.classmap['EventData'] = 'granicus:EventData'
    self.classmap['FolderData'] = 'granicus:FolderData'
    self.classmap['GroupData'] = 'granicus:GroupData'
    self.classmap['KeyMapping'] = 'granicus:KeyMapping'
    self.classmap['MetaDataData'] = 'granicus:MetaDataData'
    self.classmap['Motion'] = 'granicus:Motion'
    self.classmap['Note'] = 'granicus:Note'
    self.classmap['Rollcall'] = 'granicus:Rollcall'
    self.classmap['ServerData'] = 'granicus:ServerData'
    self.classmap['ServerInterfaceData'] = 'granicus:ServerInterfaceData'
    self.classmap['TemplateData'] = 'granicus:TemplateData'
    self.classmap['ViewData'] = 'granicus:ViewData'
    self.classmap['VoteEntry'] = 'granicus:VoteEntry'
    self.classmap['VoteRecord'] = 'granicus:VoteRecord'
    
    # create a client
    def initialize(granicus_site=nil,username=nil,password=nil,options={})
      # setup our private members
      @options = options
      @impersonation_token = nil
      @connected = false
      
      # configure savon
      Savon.configure do |config|
        config.log = false
      end
      HTTPI.log = false
      
      # connect if we have a site and credentials
      unless granicus_site.nil?
        self.site = granicus_site
      end

      unless username.nil? or password.nil?
        login(username,password)
      end
    end
    
    # options
    def options
      @options
    end
    def options=(value)
      @options = value
    end
    
    # connect up to a site
    def connect(granicus_site,username,password,options={})
      logout if @connected
      
      # create the client
      self.site = granicus_site
      
      # call login
      login username, password
    end
    
    # site property
    def site
      return @granicus_site
    end
    
    def site=(value)
      @granicus_site = value
      @client = Savon::Client.new do |wsdl, http|
        wsdl.document = File.expand_path("../granicus-platform-api.xml", __FILE__)
        wsdl.endpoint = "http://#{value}/SDK/User/index.php" 
        http.proxy = @options[:proxy] if not @options[:proxy].nil?
      end
    end
    
    # impersonate a user
    def impersonate(token)
      @impersonation_token = token
      @client.http.headers["Cookie"] = "SESS1=#{token}; path=/"
    end
    
    def impersonation_token
      @impersonation_token
    end

    # login
    def login(username,password)
      logout if @connected
      call_soap_method(:login,'//ns4:LoginResponse/return',{'Username' => username, 'Password' => password})
      @impersonation_token = @response.http.headers['Set-Cookie'].gsub(/SESS1=(.*); path=\//,'\\1')
      @connected = true
    end
    
    # return the current logged on user name
    def get_current_user_logon
      call_soap_method(:get_current_user_logon,'//ns4:GetCurrentUserLogonResponse/Logon')
    end

    # logout
    def logout
      call_soap_method(:logout,'//ns4:LogoutResponse')
      @connected = false
    end

    # return all of the cameras
    def get_cameras
      call_soap_method(:get_cameras,'//ns5:GetCamerasResponse/cameras')
    end
    
    # create a camera
    def create_camera(camera)
      call_soap_method(:create_camera,'//ns4:CreateCameraResponse/CameraID',{ 'CameraData' => camera })
    end
    
    # return the requested camera
    def get_camera(camera_id)
      call_soap_method(:get_camera,'//ns5:GetCameraResponse/camera',{ 'CameraID' => camera_id })
    end
    
    # update a camera
    def update_camera(camera)
      call_soap_method(:update_camera,'//ns4:UpdateCameraResponse',{ 'camera' => camera })
    end
    
    # delete the requested camera
    def delete_camera(camera_id)
      call_soap_method(:delete_camera,'//ns4:DeleteCameraResponse',{ 'CameraID' => camera_id})
    end

    # return all of the events
    def get_events
      call_soap_method(:get_events,'//ns5:GetEventsResponse/events')
    end
    
    # return all of the events with matching foreign id
    def get_events_by_foreign_id(foreign_id)
      call_soap_method(:get_events_by_foreign_id,'//ns5:GetEventsByForeignIDResponse/events',{ 'ForeignID' => foreign_id })
    end
    
    # create an event
    def create_event(event)
      call_soap_method(:create_event,'//ns4:CreateEventResponse/EventID',{ 'EventData' => event })
    end
    
    # return the requested event
    def get_event(event_id)
      call_soap_method(:get_event,'//ns5:GetEventResponse/event',{ 'EventID' => event_id })
    end
    
    # return the requested event by uid
    def get_event_by_uid(event_uid)
      call_soap_method(:get_event_by_uid,'//ns5:GetEventByUIDResponse/event',{ 'EventUID' => event_uid })
    end
    
    # update an event
    def update_event(event)
      call_soap_method(:update_event,'//ns4:UpdateEventResponse',{ 'event' => event })
    end
    
    # delete the requested event
    def delete_event(event_id)
      call_soap_method(:delete_event,'//ns4:DeleteEventResponse',{ 'EventID' => event_id})
    end

    # return all of the event meta data
    def get_event_meta_data(event_id)
      call_soap_method(:get_event_meta_data,'//ns5:GetEventMetaDataResponse/metadata',{ 'EventID' => event_id })
    end
    
    # import metadata for an event
    def import_event_meta_data(event_id,meta_data,clear_existing=true,as_tree=true)
      call_soap_method(:import_event_meta_data,'//ns5:ImportEventMetaDataResponse/KeyTable',{ 
        'EventID' => event_id, 
        'MetaData' => meta_data,
        'ClearExisting' => clear_existing,
        'AsTree' => as_tree})
    end
    
    # set the event agenda url
    def set_event_agenda_url(event_id,url)
      call_soap_method(:set_event_agenda_url,'//ns4:SetEventAgendaURLResponse',{ 'EventID' => event_id,  'URL' => url })
    end
    
    # return all of the clip meta data
    def get_clip_meta_data(clip_id)
      call_soap_method(:get_clip_meta_data,'//ns5:GetClipMetaDataResponse/metadata',{ 'ClipID' => clip_id })
    end
    
    # import metadata for a clip
    # ImportClipMetaData Method (ClipID, MetaData, ClearExisting, AsTree) 
    def import_clip_meta_data(clip_id,meta_data,clear_existing=true,as_tree=true)
      call_soap_method(:import_clip_meta_data,'//ns5:ImportClipMetaDataResponse/KeyTable',{ 
        'ClipID' => clip_id, 
        'MetaData' => meta_data,
        'ClearExisting' => clear_existing,
        'AsTree' => as_tree})
    end
    
    # get meta data by id
    def get_meta_data(meta_id)
      call_soap_method(:get_meta_data,'//ns5:GetMetaDataResponse/MetaData', { 'MetaDataID' => meta_id })
    end
    
    # update metadata 
    def update_meta_data(meta_data)
      call_soap_method(:update_meta_data,'//ns4:UpdateMetaDataResponse', { 'MetaData' => meta_data })
    end

    # return all of the folders
    def get_folders
      call_soap_method(:get_folders,'//ns5:GetFoldersResponse/folders')
    end

    # return all of the clips
    def get_clips(folder_id)
      call_soap_method(:get_clips,'//ns5:GetClipsResponse/clips',{ 'FolderID' => folder_id })
    end
    
    # return all of the clips with matching foreign id
    def get_clips_by_foreign_id(foreign_id)
      call_soap_method(:get_clips_by_foreign_id,'//ns5:GetClipsByForeignIDResponse/clips',{ 'ForeignID' => foreign_id })
    end
    
    # return the requested clip
    def get_clip(clip_id)
      call_soap_method(:get_clip,'//ns5:GetClipResponse/clip',{ 'ClipID' => clip_id })
    end
    
    # return the requested clip
    def get_clip_by_uid(clip_uid)
      call_soap_method(:get_clip_by_uid,'//ns5:GetClipByUIDResponse/clip',{ 'ClipUID' => clip_uid })
    end

    # get servers
    def get_servers
      call_soap_method(:get_servers,'//ns5:GetServersResponse/servers')
    end
    
    # return the requested server
    def get_server(server_id)
      call_soap_method(:get_server,'//ns5:GetServerResponse/server',{ 'ServerID' => server_id })
    end

    #private
    
    def call_soap_method(method,returnfilter,args={})
      debug = @options[:debug]
      @response = @client.request :wsdl, method do
        soap.namespaces['xmlns:granicus'] = "http://granicus.com/xsd"
        soap.namespaces['xmlns:SOAP-ENC'] = "http://schemas.xmlsoap.org/soap/encoding/"
        soap.body = prepare_hash args
        if debug then
          puts soap.body
        end
      end
      
      doc = Nokogiri::XML(@response.to_xml) do |config|
        config.noblanks
      end
      response = handle_response(doc.xpath(returnfilter, doc.root.namespaces)[0])
      if debug
        puts response
      end
      response
    end
    
    def prepare_hash(hash={})
      attributes = {}
      new_hash = {}
      hash.each do |key,value|
        case value.class.to_s
        when /GranicusPlatformAPI::/, 'Hash'
          new_hash[key] = prepare_hash value
        when 'Array'
          new_hash[key] = prepare_array value
        else
          new_hash[key] = value
        end
        attributes[key] = attribute_of value
      end
      new_hash.merge({ :attributes! => attributes })
    end
    
    def prepare_array(array)
      return { "item" => array } if array.count == 0
      new_array = []
      array.each do |item|
        case item.class.to_s
        when /GranicusPlatformAPI::/, 'Hash'
          new_array << prepare_hash(item)
        when 'Array'
          new_array << prepare_array(item)
        else
          new_array << item
        end
      end
      { "item" => new_array, :attributes! => { "item" => attribute_of(array[0]) } }
    end
    
    def attribute_of(value) 
      case value.class.to_s
      when 'Array'
        return {"xsi:type" => 'SOAP-ENC:Array'} if value.count == 0
        xsd_type = self.class.classmap[value[0].class.to_s.split('::').last]
        if xsd_type.nil? 
          puts "Couldn't get array xsd:type for #{value[0].class}"
          {"xsi:type" => 'SOAP-ENC:Array'}
        else
          {"xsi:type" => 'SOAP-ENC:Array', "SOAP-ENC:arrayType" => "#{xsd_type}[#{value.count}]"}
        end
      else
        xsd_type = self.class.classmap[value.class.to_s.split('::').last]
        if xsd_type.nil? 
          puts "Couldn't get xsd:type for #{value.class}"
          nil
        else
          {"xsi:type" => xsd_type }
        end
      end
    end

    def handle_response(node)
      if node.is_a? Nokogiri::XML::NodeSet or node.is_a? Array then
        return node.map {|el| handle_response el } 
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
          node.children.map {|element| handle_response element }
        else
          puts "Unknown SOAP-ENC:type: #{type}"
          node.to_s
        end
      else
        # we have a custom type, attempt to generate it. if that fails use a hash
        proc = self.class.typegenerators[type]
        value = {}
        unless proc.nil?
          value = proc.call
        else
          puts "Unknown custom type: #{type}"
        end
        node.children.each do |value_node|
          value[value_node.name] = handle_response value_node
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
  end
end
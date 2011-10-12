require 'helper'

GRANICUS_SITE     = ENV['GRANICUS_SITE']
GRANICUS_LOGIN    = ENV['GRANICUS_LOGIN']
GRANICUS_PASSWORD = ENV['GRANICUS_PASSWORD']

unless GRANICUS_SITE && GRANICUS_LOGIN && GRANICUS_PASSWORD
  raise "The environment variables GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD are required to be set on the system"
end

# load fixtures based on the GRANICUS_SITE environment variable
fixtures      = YAML.load(ERB.new(File.new(File.dirname(__FILE__) + '/fixtures/fixtures.yml').read).result)
site_settings = fixtures[GRANICUS_SITE]
CAMERA        = fixtures["camera"]
EVENT         = fixtures["event"]

CAMERA_ID        = site_settings["camera_id"]
FOLDER_ID        = site_settings["folder_id"]
IMPORT_EVENT_ID  = site_settings["import_event_id"]
UPDATE_EVENT_ID  = site_settings["update_event_id"]
EVENT_META_ID    = site_settings["event_meta_id"]
CLIP_ID          = site_settings["clip_id"]
IMPORT_CLIP_ID   = site_settings["import_clip_id"]
CLIP_UID         = site_settings["clip_uid"]
CLIP_META_ID     = site_settings["clip_meta_id"]
CLIP_FOREIGN_ID  = site_settings["clip_foreign_id"]
EVENT_FOREIGN_ID = site_settings["event_foreign_id"]
SERVER_ID        = site_settings["server_id"]
SITE_NAME        = site_settings["name"]

client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD

# The projects method
describe GranicusPlatformAPI, "::Client.new" do
  it "should log me in" do
    logon = client.get_current_user_logon
    logon.should == GRANICUS_LOGIN
  end

  it "should support impersonation" do
    client2 = GranicusPlatformAPI::Client.new GRANICUS_SITE, nil, nil
    client2.impersonate client.impersonation_token
    client2.get_current_user_logon.should == client.get_current_user_logon
  end

  it "should support initialize without arguments" do
    client2 = GranicusPlatformAPI::Client.new
    client2.connect(GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD)
    client2.get_current_user_logon
    client2.logout
  end
end

describe GranicusPlatformAPI, "::Client Camera Methods" do
  before do
    camera               = GranicusPlatformAPI::CameraData.new
    camera.BroadcastPort = CAMERA["BroadcastPort"]
    camera.Type          = CAMERA["Type"]
    camera.ControlPort   = CAMERA["ControlPort"]
    camera.ExternalIP    = CAMERA["ExternalIP"]
    camera.Identifier    = CAMERA["Identifier"]
    camera.InternalIP    = CAMERA["InternalIP"]
    camera.Name          = CAMERA["Name"]
    @new_camera_id       = client.create_camera camera
    @camera              = client.get_camera(@new_camera_id)
  end

  it "should create a camera" do
    @new_camera_id.should_not == nil
  end

  it "should get a camera" do
    @camera.should_not == nil
  end

  it "should get all cameras" do
    cameras = client.get_cameras
    found   = cameras.find { |c| c.ID == @camera.ID }
    found.should_not == nil
  end

  it "should retrieve and update a camera" do
    camera2      = client.get_camera @camera.ID
    camera2.Name = 'test my new camera'
    client.update_camera camera2

    camera3 = client.get_camera @camera.ID
    camera3.Name.should == 'test my new camera'
  end

  it "should delete a camera" do
    client.delete_camera @camera.ID
  end

  after do
    client.delete_camera @camera.ID
  end

end

describe GranicusPlatformAPI, "::Client Event Methods" do
  before do
    event                     = GranicusPlatformAPI::EventData.new
    event.Name                = EVENT["Name"]
    event.Duration            = EVENT["Duration"]
    event.FolderID            = EVENT["FolderID"]
    event.CameraID            = EVENT["CameraID"]
    event.ECommentEnabled     = EVENT["ECommentEnabled"]
    event.AgendaPostedDate    = EVENT["AgendaPostedDate"]
    event.Attendees           = []
    event.ECommentCloseOffset = EVENT["ECommentCloseOffset"]
    event.StartTime           = Time.now() - 300
    event.FolderID            = client.get_folders()[0].ID
    event.CameraID            = client.get_cameras()[0].ID
    @new_event_id             = client.create_event event
    @event                    = client.get_event @new_event_id
  end

  it "should create an event" do
    @new_event_id.should_not == nil
  end

  it "should get an event by ID" do
    # retrieve one
    @event.should_not == nil
  end

  it "should get an event by UID" do
    # retrieve one by UID
    event = client.get_event_by_uid @event.UID
    event.ID.should == @event.ID
  end

  it "should get all events" do
    # retrieve many
    events = client.get_events
    found  = events.find { |e| e.ID == @event.ID }
    found.should_not == nil
  end

  it "should be updatedable" do
    # update
    event      = client.get_event @event.ID
    event.Name = 'platform-api-rb unit test event updated'
    client.update_event(event)

    event2 = client.get_event @event.ID
    event2.Name.should == 'platform-api-rb unit test event updated'
  end

  it "should support metadata operations" do
    event           = client.get_event @event.ID
    event.UID       = ''
    new_event_id    = client.create_event event
    new_event       = client.get_event new_event_id
    meta_arr        = []
    meta1           = GranicusPlatformAPI::MetaDataData.new
    meta1.Name      = 'test'
    meta1.ForeignID = 1
    meta2           = GranicusPlatformAPI::MetaDataData.new
    meta2.Name      = 'test 2'
    meta2.ForeignID = 2
    meta_arr << meta1
    meta_arr << meta2
    keytable = client.import_event_meta_data new_event_id, meta_arr
    keytable[0].ForeignID.should == 1
    keytable[1].ForeignID.should == 2

    # fetch out the metadata and make sure it matches
    meta_tree = client.get_event_meta_data new_event_id
    meta_tree[0].ID.should == keytable[0].GranicusID
    meta_tree[1].ID.should == keytable[1].GranicusID

    # fetch out the metadata by UID and make sure it matches
    meta_tree = client.get_event_meta_data_by_uid new_event.UID
    meta_tree[0].ID.should == keytable[0].GranicusID
    meta_tree[1].ID.should == keytable[1].GranicusID

    client.delete_event new_event_id
  end

  it "should have the EComment-specific fields" do
    event = client.get_event @event.ID
    event.NextStartDate.should_not == nil
    event.ECommentEnabled.should_not == nil
  end

  it "should get all events with matching foreign id" do
    events = client.get_events_by_foreign_id EVENT_FOREIGN_ID
    events.each do |event|
      event.ForeignID.should == EVENT_FOREIGN_ID
    end
  end

  it "should update a simple property on requested event" do
    event = client.get_event @event.ID
    event.ID.should == @event.ID
    event.Name = 'my test'
    client.update_event event
  end

  it "should add a complex property on requested event" do
    event = client.get_event @event.ID
    event.ID.should == @event.ID
    att1        = GranicusPlatformAPI::Attendee.new
    att1.Name   = 'Foo Fighters'
    att1.Voting = true
    att1.Chair  = true
    event.Attendees << att1
    client.update_event event
  end

  it "should update a complex property on requested event" do
    # create
    event = client.get_event @event.ID
    event.ID.should == @event.ID
    att1        = GranicusPlatformAPI::Attendee.new
    att1.Name   = 'Foo Fighters'
    att1.Voting = true
    att1.Chair  = true
    event.Attendees << att1
    client.update_event event

    # update
    event                   = client.get_event @event.ID
    event.Attendees[0].Name = 'Nirvana'
    client.update_event event

    event = client.get_event @event.ID
    event.ID.should == @event.ID
    event.Attendees[0].Name.should == 'Nirvana'
  end

  it "set the event agenda url" do
    client.set_event_agenda_url @event.ID, "http://github.com/gov20cto/granicus-platform-api"
  end

  it "should delete event" do
    client.delete_event @event.ID
  end

  after do
    client.delete_event @event.ID
  end

end

describe GranicusPlatformAPI, "::EComment Methods" do
  it "should get ecomments by event id" do
    comments = client.get_ecomments_by_event_id(811)
    comments.should be_kind_of(Array)
  end

  it "should get ecomments by agenda item uid" do
    comments = client.get_ecomments_by_agenda_item_uid("42a8238d-7638-102e-bb2d-9326039e1073")
    comments.should be_kind_of(Array)
  end
end

describe GranicusPlatformAPI, "::Client Folder Methods" do
  it "should get my folders" do
    folders = client.get_folders
    found   = folders.find { |f| f.ID == FOLDER_ID }
    found.should_not == nil
  end
end

describe GranicusPlatformAPI, "::Client Clip Methods" do
  it "should get clips from the given folder" do
    clips = client.get_clips FOLDER_ID
    clips.each do |clip|
      clip.FolderID.should == FOLDER_ID
    end
  end

  it "should get all clips with matching foreign id" do
    clips = client.get_clips_by_foreign_id CLIP_FOREIGN_ID
    clips.each do |clip|
      clip.ForeignID.should == CLIP_FOREIGN_ID
    end
  end

  it "should get the requested clip" do
    clip = client.get_clip CLIP_ID
    clip.ID.should == CLIP_ID
  end

  it "should update the given clip" do
    clip      = client.get_clip CLIP_ID
    name      = clip.Name
    clip.Name = 'this is my test name'
    client.update_clip clip
    clip2 = client.get_clip CLIP_ID
    clip2.Name.should == 'this is my test name'
    clip2.Name = name
    client.update_clip clip2
  end

  it "should get the requested clip by UID" do
    clip = client.get_clip_by_uid CLIP_UID
    clip.UID.should == CLIP_UID
  end

  it "should import metadata" do
    meta_arr        = []
    meta1           = GranicusPlatformAPI::MetaDataData.new
    meta1.Name      = 'test'
    meta1.TimeStamp = 0
    meta1.ForeignID = 1
    meta2           = GranicusPlatformAPI::MetaDataData.new
    meta2.Name      = 'test 2'
    meta2.TimeStamp = 30
    meta2.ForeignID = 2
    meta_arr << meta1
    meta_arr << meta2
    keytable = client.import_clip_meta_data IMPORT_CLIP_ID, meta_arr
    keytable[0].ForeignID.should == 1
    keytable[1].ForeignID.should == 2
  end
end

describe GranicusPlatformAPI, "::Client MetaData Methods" do

  it "should get a clip's meta data" do
    metadata = client.get_clip_meta_data CLIP_ID
    found    = metadata.find { |m| m.ID == CLIP_META_ID }
    found.should_not == nil
  end

  it "should get the requested meta data" do
    metadata    = client.get_meta_data CLIP_META_ID
    metadata.ID = CLIP_META_ID
  end

  it "should support uploading and downloading documents" do
    document                = GranicusPlatformAPI::Document.new
    document.Description    = "My test document"
    document.FileContents   = fixture('About Stacks.pdf')
    document.FileExtension  = document.FileContents.path.split('.').last
    document_meta           = GranicusPlatformAPI::MetaDataData.new
    document_meta.Name      = 'test doc'
    document_meta.ForeignID = 2
    document_meta.Payload   = document
    document_meta.ParentID  = CLIP_META_ID
    keymap                  = client.add_clip_meta_data CLIP_ID, document_meta
    attachment              = client.fetch_attachment keymap[0].GranicusID
    attachment.FileExtension.should == document.FileExtension
    attachment.FileContents.length.should == document.FileContents.size
  end

  it "should update the metadata" do
    metadata      = client.get_meta_data CLIP_META_ID
    old_name      = metadata.Name
    metadata.Name = 'test'
    client.update_meta_data metadata
    client.get_meta_data(CLIP_META_ID).Name.should == 'test'
    metadata.Name = old_name
    client.update_meta_data metadata
  end
end

describe GranicusPlatformAPI, "::Client Server Methods" do
  it "should get all servers" do
    servers = client.get_servers
    found   = servers.find { |s| s.ID == SERVER_ID }
    found.should_not == nil
  end

  it "should get the requested server" do
    server = client.get_server SERVER_ID
    server.ID.should == SERVER_ID
  end
end

describe GranicusPlatformAPI, "::Settings Methods" do
  it "should support getting settings" do
    settings = client.get_settings
    found    = settings.find { |s| s.Name == "name" && s.Value == SITE_NAME }
    found.should_not == nil
  end
  it "should not return database setting" do
    settings = client.get_settings
    found    = settings.find { |s| s.Name == "database" }
    found.should == nil
  end
end

describe GranicusPlatformAPI, "::Client.logout" do
  it "should log me out" do
    value = client.logout
  end
end

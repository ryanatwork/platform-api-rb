require 'helper'

# these environment variables are required to be set on the system
GRANICUS_SITE     = ENV['GRANICUS_SITE']
GRANICUS_LOGIN    = ENV['GRANICUS_LOGIN']
GRANICUS_PASSWORD = ENV['GRANICUS_PASSWORD']

# grab different fixtures, based on the GRANICUS_SITE environment variable
fixtures = YAML.load(ERB.new(File.new(File.dirname(__FILE__) + '/fixtures/fixtures.yml').read).result)[GRANICUS_SITE]

CAMERA_ID        = fixtures["camera_id"]
FOLDER_ID        = fixtures["folder_id"]
EVENT_ID         = fixtures["event_id"]
EVENT_UID        = fixtures["event_uid"]
IMPORT_EVENT_ID  = fixtures["import_event_id"]
UPDATE_EVENT_ID  = fixtures["update_event_id"]
EVENT_META_ID    = fixtures["event_meta_id"]
CLIP_ID          = fixtures["clip_id"]
IMPORT_CLIP_ID   = fixtures["import_clip_id"]
CLIP_UID         = fixtures["clip_uid"]
CLIP_META_ID     = fixtures["clip_meta_id"]
CLIP_FOREIGN_ID  = fixtures["clip_foreign_id"]
EVENT_FOREIGN_ID = fixtures["event_foreign_id"]
SERVER_ID        = fixtures["server_id"]

# TODO: Delete then create an Event fixture here.

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
  it "should get my cameras" do
    cameras = client.get_cameras
    found   = cameras.find { |c| c.ID == CAMERA_ID }
    found.should_not == nil
  end

  it "should create, retrieve, update and delete a camera" do
    camera        = client.get_camera CAMERA_ID
    new_camera_id = client.create_camera camera
    camera2       = client.get_camera new_camera_id
    camera2.Name  = 'test my new camera'
    client.update_camera camera2
    camera3 = client.get_camera new_camera_id
    camera3.Name.should == 'test my new camera'
    client.delete_camera new_camera_id
  end
end

describe GranicusPlatformAPI, "::Client Event Methods" do
  it "should get all events" do
    events = client.get_events
    found  = events.find { |e| e.ID == EVENT_ID }
    found.should_not == nil
  end

  it "should get the requested event" do
    event        = client.get_event EVENT_ID
    event.UID    = ''
    new_event_id = client.create_event event
    event2       = client.get_event new_event_id
    event2.Name  = 'test my new event'
    client.update_event event2
    event3 = client.get_event new_event_id
    event3.Name.should == 'test my new event'
    client.delete_event new_event_id
  end

  it "should have the NextStartDate and AgendaRolloverID fields" do
    event = client.get_event EVENT_ID
    event.NextStartDate.should_not == nil
    event.AgendaRolloverID.should_not == nil
  end

  it "should import metadata" do
    meta_arr        = []
    meta1           = GranicusPlatformAPI::MetaDataData.new
    meta1.Name      = 'test'
    meta1.ForeignID = 1
    meta2           = GranicusPlatformAPI::MetaDataData.new
    meta2.Name      = 'test 2'
    meta2.ForeignID = 2
    meta_arr << meta1
    meta_arr << meta2
    keytable = client.import_event_meta_data IMPORT_EVENT_ID, meta_arr
    keytable[0].ForeignID.should == 1
    keytable[1].ForeignID.should == 2
  end

  it "should get all events with matching foreign id" do
    events = client.get_events_by_foreign_id EVENT_FOREIGN_ID
    events.each do |event|
      event.ForeignID.should == EVENT_FOREIGN_ID
    end
  end

  it "should update a simple property on requested event" do
    event = client.get_event UPDATE_EVENT_ID
    event.ID.should == UPDATE_EVENT_ID
    event.Name = 'my test'
    client.update_event event
  end

  it "should add a complex property on requested event" do
    event = client.get_event UPDATE_EVENT_ID
    event.ID.should == UPDATE_EVENT_ID
    event.Attendees << {'Name' => "Foo Fighters", 'Voting' => true, 'Chair' => true}
    client.update_event event
  end

  it "should update a complex property on requested event" do
    event = client.get_event UPDATE_EVENT_ID
    event.ID.should == UPDATE_EVENT_ID
    event.Attendees[0].Name = 'my test'
    client.update_event event
  end

  it "should get the requested event by UID" do
    event = client.get_event_by_uid EVENT_UID
    event.UID.should == EVENT_UID
  end

  it "set the event agenda url" do
    event = client.set_event_agenda_url EVENT_ID, "http://github.com/gov20cto/granicus-platform-api"
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
  it "should get an event's meta data" do
    metadata = client.get_event_meta_data EVENT_ID
    puts metadata
    found = metadata.find { |m| m.ID == EVENT_META_ID }
    found.should_not == nil
  end

  it "should get an event's meta data by UID" do
    metadata = client.get_event_meta_data_by_uid EVENT_UID
    found    = metadata.find { |m| m.ID == EVENT_META_ID }
    found.should_not == nil
  end

  it "should get a clip's meta data" do
    metadata = client.get_clip_meta_data CLIP_ID
    found    = metadata.find { |m| m.ID == CLIP_META_ID }
    found.should_not == nil
  end

  it "should get the requested meta data" do
    metadata    = client.get_meta_data CLIP_META_ID
    metadata.ID = CLIP_META_ID
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

describe GranicusPlatformAPI, "::Client.logout" do
  it "should log me out" do
    value = client.logout
  end
end

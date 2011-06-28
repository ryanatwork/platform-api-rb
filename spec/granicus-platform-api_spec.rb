require 'helper'

GRANICUS_SITE = ENV['SITE']
GRANICUS_LOGIN = ENV['USERNAME']
GRANICUS_PASSWORD = ENV['PASSWORD']
CAMERA_ID = 3
FOLDER_ID = 7
EVENT_ID = 30
UPDATE_EVENT_ID = 35
EVENT_META_ID = 1775
CLIP_ID = 246
CLIP_UID = '00000000-0000-0000-0000-000000000000'
EVENT_UID = '00000000-0000-0000-0000-000000000000'
CLIP_META_ID = 574
CLIP_FOREIGN_ID = 1
EVENT_FOREIGN_ID = 1
SERVER_ID = 2

client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD, {:proxy => 'http://localhost:8888'}

# The projects method
describe GranicusPlatformAPI, "::Client.new" do
  it "should log me in" do
    logon = client.get_current_user_logon
    logon.should == GRANICUS_LOGIN
  end
end

describe GranicusPlatformAPI, "::Client Camera Methods" do
  it "should get my cameras" do
    cameras = client.get_cameras
    found = cameras.find {|c| c.ID == CAMERA_ID } 
    found.should_not == nil
  end
  it "should create, retreive, update and delete a camera" do
    camera = client.get_camera CAMERA_ID
    new_camera_id = client.create_camera camera
    camera2 = client.get_camera new_camera_id
    camera2.Name = 'test my new camera'
    client.update_camera camera2
    camera3 = client.get_camera new_camera_id
    camera3.Name.should == 'test my new camera'
    client.delete_camera new_camera_id
  end
end

describe GranicusPlatformAPI, "::Client Event Methods" do
  it "should get all events" do
     events = client.get_events
     found = events.find {|e| e.ID == EVENT_ID } 
     found.should_not == nil
  end
  it "should get the requested event" do
    event = client.get_event EVENT_ID
    event.UID = ''
    new_event_id = client.create_event event
    event2 = client.get_event new_event_id
    event2.Name = 'test my new event'
    client.update_event event2
    event3 = client.get_event new_event_id
    event3.Name.should == 'test my new event'
    client.delete_event new_event_id
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
    event.Attendees << { 'Name' => "Foo Fighters", 'Voting' => true, 'Chair' => true }
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
    folders[0].ID.should == FOLDER_ID
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
  it "should get the requested clip by UID" do
    clip = client.get_clip_by_uid CLIP_UID
    clip.ID.should == CLIP_UID
  end
end

describe GranicusPlatformAPI, "::Client MetaData Methods" do
  it "should get an event's meta data" do
    metadata = client.get_event_meta_data EVENT_ID
    found = metadata.find {|m| m.ID == EVENT_META_ID } 
    found.should_not == nil
  end
  it "should get a clip's meta data" do
    metadata = client.get_clip_meta_data CLIP_ID
    found = metadata.find {|m| m.ID == CLIP_META_ID } 
    found.should_not == nil
  end
  
  it "should get the requested meta data" do
    metadata = client.get_meta_data CLIP_META_ID
    metadata.ID = CLIP_META_ID
    puts metadata
  end
end

describe GranicusPlatformAPI, "::Client Server Methods" do
  it "should get all servers" do
    servers = client.get_servers
    found = servers.find {|s| s.ID == SERVER_ID } 
    found.should_not == nil
  end
  it "should get the requested server" do
    server = client.get_server SERVER_ID
    server.ID.should == SERVER_D
  end
end

describe GranicusPlatformAPI, "::Client.logout" do
  it "should log me out" do
    value = client.logout
  end
end
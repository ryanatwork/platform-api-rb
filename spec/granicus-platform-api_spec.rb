require 'helper'

GRANICUS_SITE = ENV['SITE']
GRANICUS_LOGIN = ENV['USERNAME']
GRANICUS_PASSWORD = ENV['PASSWORD']
CAMERA_ID = 3
FOLDER_ID = 7
SERVER_ID = 1
EVENT_ID = 10
EVENT_ID2 = 30
EVENT_META_ID = 1775

client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD 

# The projects method
describe GranicusPlatformAPI, "::Client.login" do
  it "should log me in" do
    logon = client.get_current_user_logon
    logon.should == GRANICUS_LOGIN
  end

end

describe GranicusPlatformAPI, "::Client.get_cameras" do
  it "should get my cameras" do
    cameras = client.get_cameras
    cameras[0].id.should == CAMERA_ID
  end
end

describe GranicusPlatformAPI, "::Client.get_events" do
  it "should get my events" do
    events = client.get_events
    events[0].id.should == EVENT_ID
  end
end

describe GranicusPlatformAPI, "::Client.get_folders" do
  it "should get my folders" do
    folders = client.get_folders
    folders[0].id.should == FOLDER_ID
  end
end

describe GranicusPlatformAPI, "::Client.get_clips" do
  it "should get clips from the given folder" do
    clips = client.get_clips FOLDER_ID
    clips.each do |clip|
      clip.folder_id.should == FOLDER_ID
    end
  end
end

describe GranicusPlatformAPI, "::Client.get_event_meta_data" do
  it "should get my event meta data" do
    metadata = client.get_event_meta_data EVENT_ID2
    found = metadata.find {|m| m.id == EVENT_META_ID } 
    found.should_not == nil
  end
end

describe GranicusPlatformAPI, "::Client.get_servers" do
  it "should get my servers" do
    servers = client.get_servers
    puts servers
    servers[0].id.should == SERVER_ID
  end
end

describe GranicusPlatformAPI, "::Client.logout" do
  it "should log me out" do
    value = client.logout
  end
end
require 'helper'

GRANICUS_SITE = ENV['SITE']
GRANICUS_LOGIN = ENV['USERNAME']
GRANICUS_PASSWORD = ENV['PASSWORD']
CAMERA_ID = "3"
FOLDER_ID = "7"
SERVER_ID = "1"

# The projects method
describe GranicusPlatformAPI, "::Client.login" do

  it "should not return an error" do
    client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD 
  end
  
  it "should log me in" do
    client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD 
    logon = client.get_current_user_logon
    logon.should == GRANICUS_LOGIN
  end

end

describe GranicusPlatformAPI, "::Client.get_cameras" do
  it "should get my cameras" do
    client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD 
    cameras = client.get_cameras
    cameras[0].id.should == CAMERA_ID
  end
end

describe GranicusPlatformAPI, "::Client.get_folders" do
  it "should get my folders" do
    client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD 
    folders = client.get_folders
    folders[0].id.should == FOLDER_ID
  end
end

describe GranicusPlatformAPI, "::Client.get_clips" do
  it "should get my clips" do
    client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD 
    clips = client.get_clips FOLDER_ID
    puts clips
  end
end

describe GranicusPlatformAPI, "::Client.get_servers" do
  it "should get my servers" do
    client = GranicusPlatformAPI::Client.new GRANICUS_SITE, GRANICUS_LOGIN, GRANICUS_PASSWORD 
    servers = client.get_servers
    puts servers
    servers[0].id.should == SERVER_ID
  end
end
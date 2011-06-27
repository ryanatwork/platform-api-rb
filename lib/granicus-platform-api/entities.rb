require 'hashie'

module GranicusPlatformAPI
  
  class CameraData < Hashie::Mash
    def cameradata
      @@name = 'CameraData'
    end
  end
  
  class EventData < Hashie::Dash
    property :ID
    property :UID
    property :ForeignID
    property :Name
    property :CameraID
    property :FolderID
    property :AgendaType
    property :AgendaFile
    property :PlayerTemplateID
    property :ArchiveStatus
    property :Duration
    property :Broadcast
    property :Record
    property :AutoStart
    property :StartTime
    property :LastModified
    property :Attendees
    property :MotionTypes
    property :Street1
    property :Street2
    property :City
    property :State
    property :Zip
    property :AgendaTitle
    property :MeetingTime
    property :AgendaPostedDate
  end
  
  class Attendee < Hashie::Dash
    property :ID
    property :Name
    property :OrderID
    property :Voting
    property :Chair
  end
end
require 'hashie'

module GranicusPlatformAPI
  class AgendaItem < Hashie::Dash
    property :Department
    property :Actions
  end
  
  class Attendee < Hashie::Dash
    property :ID
    property :Name
    property :OrderID
    property :Voting
    property :Chair
  end
  
  class AttendeeStatus < Hashie::Dash
    property :Name
    property :Status
  end
  
  class CameraData < Hashie::Dash
    property :ID
    property :Type
    property :Name
    property :InternalIP
    property :ExternalIP
    property :BroadcastPort
    property :ControlPort
    property :Identifier
  end
  
  class ClipData < Hashie::Dash
    property :ID
    property :UID
    property :ForeignID
    property :Type
    property :Name
    property :Description
    property :Keywords
    property :Date
    property :CameraID
    property :FolderID
    property :FileName
    property :MinutesType
    property :MinutesFile
    property :AgendaType
    property :AgendaFile
    property :Duration
    property :Status
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
    property :AgendaPostedDate
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
  
  class FolderData < Hashie::Dash
    property :ID
    property :Name
    property :Description
    property :Type
    property :PlayerTemplateID
    property :CreatedDate
    property :Views
    property :Servers
  end
  
  class MetaDataData < Hashie::Dash
    property :ID
    property :UID
    property :ParentID
    property :ParentUID
    property :ForeignID
    property :SourceID
    property :Name
    property :TimeStamp
    property :OrderID
    property :Payload
    property :Children
  end
  
  class Rollcall < Hashie::Dash
    property :Attendees
  end
end
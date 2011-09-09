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
  
  class CaptionData < Hashie::Dash
    property :Caption
    property :TimeStamp
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
  
  class Document < Hashie::Dash
    property :Description
    property :Location
    property :FileContents
    property :FileExtension
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
    property :NextStartDate
    property :Status
    property :AgendaRolloverID
    property :ECommentEnabled
    property :ECommentCloseOffset
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

  class GroupData < Hashie::Dash
    property :ID
    property :Name
    property :Description
    property :CreatedDate
  end
  
  class KeyMapping < Hashie::Dash
    property :ForeignID
    property :GranicusID
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
    property :AllowComment
  end
  
  class Motion < Hashie::Dash
    property :Mover
    property :Seconder
    property :Type
    property :MotionText
  end
  
  class Note < Hashie::Dash
    property :NoteText
    property :EditorsNotes
    property :Private
  end
  
  class Rollcall < Hashie::Dash
    property :Attendees
  end
  
  class ServerData < Hashie::Dash
    property :ID
    property :Name
    property :ControlPort
    property :FirewallCompatibility
    property :Multicast
    property :LoadBalancerScore
    property :ReplicationUN
    property :ReplicationPW
    property :CreatedDate
  end
  
  class ServerInterfaceData < Hashie::Dash
    property :ID
    property :ServerID
    property :Name
    property :Host
    property :ControlPort
    property :Directory
    property :ReplicationUN
    property :ReplicationPW
  end
  
  class TemplateData < Hashie::Dash
    property :ID
    property :Name
    property :Description
    property :Type
    property :LastModified
    property :CreatedDate
  end
  
  class ViewData < Hashie::Dash
    property :ID
    property :ForeignID
    property :Name
    property :IsActive
    property :Events
    property :Folders
  end
  
  class VoteEntry < Hashie::Dash
    property :Name
    property :Vote
  end
  
  class VoteRecord < Hashie::Dash
    property :MotionID
    property :Passed
    property :Votes
  end
end
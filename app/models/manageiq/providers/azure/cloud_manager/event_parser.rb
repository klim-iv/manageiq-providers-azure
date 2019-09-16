module ManageIQ::Providers::Azure::CloudManager::EventParser
  extend ManageIQ::Providers::Azure::EventCatcherMixin

  INSTANCE_TYPE = "microsoft.compute/virtualmachines".freeze

  def self.event_to_hash(event, ems_id)
    log_header = "ems_id: [#{ems_id}] " unless ems_id.nil?
    event_type = parse_event_type(event)
    _log.debug("#{log_header}event: [#{event_type}]")

    event_hash = {
      :source     => "AZURE",
      :timestamp  => event["eventTimestamp"],
      :message    => event["description"].presence || event["operationName"]["localizedValue"].presence,
      :ems_id     => ems_id,
      :event_type => event_type,
      :full_data  => event,
      :ems_ref    => event["eventDataId"],
      :chain_id   => event["correlationId"]
    }

    resource_type = event["resourceType"]["value"].to_s.downcase
    event_hash[:vm_uid_ems] = event_hash[:vm_ems_ref] = parse_vm_ref(event) if resource_type == INSTANCE_TYPE

    event_hash
  end
end

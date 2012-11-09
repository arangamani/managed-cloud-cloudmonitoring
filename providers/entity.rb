include Rackspace::CloudMonitoring

require 'ipaddr'

action :create do
  # normalize the ip's
  if new_resource.ip_addresses then
    new_ips = {}
    new_resource.ip_addresses.each {|k, v| new_ips[k] = IPAddr.new(v).to_string }
    new_resource.ip_addresses.update new_ips
  end
  entity = cm.entities.new(:label => new_resource.label, :ip_addresses => new_resource.ip_addresses,
                           :metadata => new_resource.metadata, :agent_id => new_resource.agent_id)
  if @current_resource.nil? then
    entity.save
    new_resource.updated_by_last_action(true)
    clear
  else
    # Compare attributes
    if !entity.compare? @current_resource then
      # It's different
      entity.id = @current_resource.id
      entity.save
      new_resource.updated_by_last_action(true)
      clear
    else
      new_resource.updated_by_last_action(false)
    end
  end
end

action :delete do
  if !@current_resource.nil? then
    @current_resource.destroy
    new_resource.updated_by_last_action(true)
    clear
  else
    new_resource.updated_by_last_action(false)
  end
end


def load_current_resource
  #@current_resource = get_entity_by_id node['cloud_monitoring']['entity_id']
  @current_resource = get_entity_by_ip node[:ipaddress]
   if @current_resource == nil then
    @current_resource = get_entity_by_label @new_resource.label
    node.set['cloud_monitoring']['entity_id'] = @current_resource.identity unless @current_resource.nil?
  end
end

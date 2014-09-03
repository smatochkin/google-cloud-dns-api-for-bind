require 'sinatra'
require 'json'
require 'yaml'
require_relative 'dns_helper'
require_relative 'response_helper'
require_relative 'hash_helper'
require 'dnsruby'

class DnsService < Sinatra::Base
  
  configure do
    enable :logging
    
    helpers ResponseHelper

    SETTINGS_FILENAME = 'config/settings.yml'
    YAML.load_file(SETTINGS_FILENAME).each do |k,v|
      set *k, v
    end
  end
  
  #configure the Sinatra app
  use Rack::Auth::Basic do |username, password|
    credentials = settings.basic_auth
    username == credentials.fetch('username') and password == credentials.fetch('password')
  end

  #declare the routes used by the app

  # Project
  # https://developers.google.com/cloud-dns/api/v1beta1/projects/get
  get "/projects/:project_name" do |project_name|
    content_type :json

    project = settings.projects[project_name]
    project_not_found!(project_name) unless project

    status 200
    project.select{|k| k != 'managedZones'}.to_json
  end

  # Managed Zones list
  # https://developers.google.com/cloud-dns/api/v1beta1/managedZones/list
  get "/projects/:project_name/managedZones" do |project_name|
    content_type :json

    project = settings.projects[project_name]
    project_not_found!(project_name) unless project
    
    status 200
    {
      :kind => "dns#managedZonesListResponse",
      :managedZones => project['managedZones']
    }.to_json
  end
  
  # Managed Zones details
  # https://developers.google.com/cloud-dns/api/v1beta1/managedZones/get
  get "/projects/:project/managedZones/:zone" do |project_name, zone_name|
    content_type :json

    project = settings.projects[project_name]
    project_not_found!(project_name) unless project
    
    zone = project['managedZones'].select{|z| z['name'] == zone_name}.first
    zone_not_found!(zone_name) unless zone
    
    status 200
    project['managedZones'].select{|z| z['name'] == zone_name}.first.to_json
  end

  # RR Sets list
  # https://developers.google.com/cloud-dns/api/v1beta1/resourceRecordSets/list
  get "/projects/:project/managedZones/:zone/rrsets" do |project_name, zone_name|
    content_type :json

    project = settings.projects[project_name]
    project_not_found!(project_name) unless project
    
    zone = project['managedZones'].select{|z| z['name'] == zone_name}.first
    zone_not_found!(zone_name) unless zone

    rrsets = rr_filter(getZone(zone['dnsName'], settings.servers['servers'] || zone['nameServers'], settings.servers['tsig']))
    rrsets.select!{|rrset| rrset[:name] == params[:name]} if params[:name]
    status 200
    {
      'kind' => 'dns#resourceRecordSetsListResponse',
      'rrsets' => rrsets
    }.to_json
  end
  
  # Changes: create
  # https://developers.google.com/cloud-dns/api/v1beta1/changes/create
  post "/projects/:project/managedZones/:zone/changes" do |project_name, zone_name|
    content_type :json

    project = settings.projects[project_name]
    project_not_found!(project_name) unless project

    zone = project['managedZones'].select{|z| z['name'] == zone_name}.first

    rd = JSON.parse(request.body.read, {:symbolize_names => true})

    # halt 400, {}, {:message=>'Change kind is missed or incorrect'}.to_json if rd[:kind] != 'dns#change'
    
    servers = settings.servers
    res = Dnsruby::Resolver.new({:nameserver => servers['servers']})
    res.dnssec = false
    tsig = Dnsruby::RR::TSIG.create(Hash[servers['tsig'].map{|k,v| [k.to_sym,v]}].merge({:type=>'TSIG', :klass=>'ANY'}))
    update = Dnsruby::Update.new(zone['dnsName'])
    if rd[:deletions]
      rd[:deletions].each do |deletion|
        deletion[:rrdatas].each do |rrdata|
          update.delete(deletion[:name], deletion[:type], rrdata)
        end
      end
    end
    if rd[:additions]
      rd[:additions].each do |addition|
        addition[:rrdatas].each do |rrdata|
          update.add(addition[:name], addition[:type], addition[:ttl], rrdata)
        end
      end
    end
    tsig.apply(update)
    response = res.send_message(update)      

    halt 500, {}, {:message=>"Unknown error. Response code #{response.rcode.to_s}"}.to_json if response.rcode != Dnsruby::RCode.NOERROR
    
    status 200
    rd.merge({
      :kind => 'dns#change',
      :id => rand(2**31 - 1),
      :status => 'done',
      :startTime => Time.now.to_datetime.rfc3339
    }).to_json
  end

end

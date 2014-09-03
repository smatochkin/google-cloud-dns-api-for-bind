require_relative 'spec_helper'

describe '# Managed Zones API' do
  before do
    authWithUser('admin')
  end

  describe 'GET /projects/<project>/managedZones' do
    before do
      get '/projects/my-dns/managedZones'
    end

    it 'responds with "200 OK"' do
      expect(last_response).to be_ok
    end

    it 'responds with content type "application/json"' do
      expect(last_response.header['Content-Type']).to include 'application/json'
    end

    it 'response data is json formatted and contains "kind" value equal "dns#managedZonesListResponse"' do
      expect(json).to include('kind' => 'dns#managedZonesListResponse')
      expect(json).to include('managedZones')
    end

    it 'response data contains a list of zones with valid data structure' do
      expect(json['managedZones']).to be_an Array
      expect(json['managedZones'].length).to be > 0
      expect(json['managedZones']).to all(be_a Hash)
      expect(json['managedZones']).to all(include('kind', 'dnsName', 'name', 'id', 'nameServers'))
      expect(json['managedZones']).to all(include('kind' => 'dns#managedZone'))
    end
  end

  describe 'GET /projects/<project>/managedZones/<zone>' do
    before do
      get "/projects/my-dns/managedZones/#{RSpec.configuration.zone}"
    end

    it 'responds with "200 OK"' do
      expect(last_response).to be_ok
    end

    it 'responds with content type "application/json"' do
      expect(last_response.header['Content-Type']).to include 'application/json'
    end

    it 'response data is json formatted and contains a valid zone definition' do
      expect(json).to be_a Hash
      expect(json).to include('dnsName', 'name', 'id', 'nameServers')
      expect(json).to include('kind' => 'dns#managedZone')
      expect(json['nameServers']).to be_an Array
    end
  end

  # Negative responses for invalid projects
  describe 'GET /projects/<invalid project>/managedZones' do
    before do
      get '/projects/bar/managedZones'
    end

    it 'responds with "403 Forbidden"' do
      expect(last_response).to be_forbidden
    end

    it 'responds with content type "application/json"' do
      expect(last_response.header['Content-Type']).to include 'application/json'
    end

    it 'response data is json formatted and contains valid "code", "error.code" and "error.message"' do
      expect(json).to be_a Hash
      expect(json).to include('error')
      expect(json['error']).to be_a Hash
      expect(json['error']).to include('code' => 403)
      expect(json['error']).to include('message' => "Unknown project bar")
    end
  end

  describe 'GET /projects/<invalid project>/managedZones/<zone>' do
    before do
      get "/projects/bar/managedZones/#{RSpec.configuration.zone}"
    end

    it 'responds with "403 Forbidden"' do
      expect(last_response).to be_forbidden
    end

    it 'responds with content type "application/json"' do
      expect(last_response.header['Content-Type']).to include 'application/json'
    end

    it 'response data is json formatted and contains valid "code", "error.code" and "error.message"' do
      expect(json).to be_a Hash
      expect(json).to include('error')
      expect(json['error']).to be_a Hash
      expect(json['error']).to include('code' => 403)
      expect(json['error']).to include('message' => "Unknown project bar")
    end
  end

  # Negative response for invalid zone
  describe 'GET /projects/<project>/managedZones/<invalid zone>' do
    before do
      get '/projects/my-dns/managedZones/bar'
    end

    it 'responds with "404 Not Found"' do
      expect(last_response).to be_not_found
    end

    it 'responds with content type "application/json"' do
      expect(last_response.header['Content-Type']).to include 'application/json'
    end

    it 'response data is json formatted and contains valid "code", "error.code" and "error.message"' do
      expect(json).to be_a Hash
      expect(json).to include('error')
      expect(json['error']).to be_a Hash
      expect(json['error']).to include('code' => 404)
      expect(json['error']).to include('message' => "The 'parameters.managedZone' resource named 'bar' does not exist.")
    end
  end
end

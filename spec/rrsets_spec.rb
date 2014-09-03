require_relative 'spec_helper'

shared_examples 'rrsets query' do
  it 'responds with "200 OK"' do
    expect(last_response).to be_ok
  end

  it 'responds with content type "application/json"' do
    expect(last_response.header['Content-Type']).to include 'application/json'
  end

  it 'response data is json formatted and contains "rrsets" and correct "kind" type' do
    expect(json).to be_a Hash
    expect(json).to include('kind' => 'dns#resourceRecordSetsListResponse')
    expect(json).to include('rrsets')
  end

  it 'response data contains a list of valid rrsets' do
    rrsets = json['rrsets']
    expect(rrsets).to be_an Array
    expect(rrsets.length).to be > 0
    expect(rrsets).to all(be_a Hash)
    expect(rrsets).to all(include('kind', 'name', 'type', 'ttl', 'rrdatas'))
    expect(rrsets).to all(include('kind' => 'dns#resourceRecordSet'))
    expect(rrsets).to all(satisfy{|rrset| expect(rrset['name']).to be_a String})
    expect(rrsets).to all(satisfy{|rrset| expect(rrset['type']).to be_a String})
    expect(rrsets).to all(satisfy{|rrset| expect(rrset['ttl']).to be_a Fixnum})
    expect(rrsets).to all(satisfy{|rrset| expect(rrset['rrdatas']).to be_an Array})
  end
end

shared_examples 'a request with invalid project name' do
  it 'responds with "403 Forbidden"' do
    expect(last_response).to be_forbidden
  end

  it 'response with content type "application/json"' do
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

describe '# RR Sets API' do
  before do
    authWithUser('admin')
  end

  describe 'GET /projects/<project>/managedZones/<zone>/rrsets' do
    before do
      get "/projects/my-dns/managedZones/#{RSpec.configuration.zone}/rrsets"
    end

    it_behaves_like 'rrsets query' do
    end
  end
  
  # Limit output to specific FQDN
  describe 'GET /projects/<project>/managedZones/<zone>/rrsets?name=<name>' do
    before do
      get "/projects/my-dns/managedZones/#{RSpec.configuration.zone}/rrsets", {:name => RSpec.configuration.test_rr}
    end

    it_behaves_like 'rrsets query' do
    end

    describe 'and handles parameter "name" to limit rrsets to specific FQDN' do
      it 'response data is limited to rrsets with name matching request parameter name' do
        rrsets = json['rrsets']
        expect(rrsets).to all(include('name' => RSpec.configuration.test_rr))
      end
    end
  end

  # Negative response on invalid project
  describe 'GET /projects/<invalid project>/managedZones/<zone>/rrsets' do
    before do
      get "/projects/bar/managedZones/#{RSpec.configuration.zone}/rrsets"
    end

    it_behaves_like 'a request with invalid project name' do
    end
  end

  # Negative response for invalid zone
  describe 'GET /projects/<project>/managedZones/<invalid zone>/rrsets' do
    before do
      get '/projects/my-dns/managedZones/bar/rrsets'
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

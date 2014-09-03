require_relative 'spec_helper'

describe '# Projects API' do
  before do
    authWithUser('admin')
  end

  describe 'GET /projects/<project>' do
    before do
      get '/projects/my-dns'
    end

    it 'responds with "200 OK"' do
      expect(last_response).to be_ok
    end

    it 'responds with content type "application/json"' do
      expect(last_response.header['Content-Type']).to include 'application/json'
    end

    it 'response data is json formatted and contains "kind" value equal "dns#project"' do
      expect(json).to include('kind' => 'dns#project')
    end
  end

  # Negative response on invalid project
  describe 'GET /projects/<invalid project>' do
    before do
      get '/projects/bar'
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
end
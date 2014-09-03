require_relative 'spec_helper'

describe '# Authorization' do
  it 'enforces authentication via "401 Unauthorized"' do
    get '/projects/my-dns'
    expect(last_response.status).to eq 401
  end

  it 'responds with "200 OK" once authenticated' do
    authWithUser('admin')
    get '/projects/my-dns'
    expect(last_response).to be_ok
  end
end

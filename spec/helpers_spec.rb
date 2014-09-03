require_relative 'spec_helper'

describe '# Hash.to_sym helper' do
  it 'converts string hash keys to symbol keys' do
    expect({'foo' => 'bar', 'one' => 1}.to_sym).to include(:foo => 'bar', :one => 1)
  end
  it 'does not convert non string hash keys' do
    expect({'foo' => 'bar', :one => 1, 2 => 'two'}.to_sym).to include(:foo => 'bar', :one => 1, 2 => 'two')
  end
end

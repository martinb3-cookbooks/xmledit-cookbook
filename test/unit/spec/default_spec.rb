# Encoding: utf-8

require_relative 'spec_helper'

# this will pass on templatestack, fail elsewhere, forcing you to
# write those chefspec tests you always were avoiding
describe 'xmledit-test::default' do
  before { stub_resources }

  let(:chef_run) do
    # step_into the ruby block so we can test recipe includes
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '14.04', step_into: ['']) do |node|
      node_resources(node)
    end.converge(described_recipe)
  end

  it 'should be a truthy chef run' do
    expect(chef_run).to be_truthy
  end
end

# Encoding: utf-8
require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'

def node_resources(_node)
end

def stub_resources
  stub_command('which sudo').and_return('/usr/bin/sudo')
end

at_exit { ChefSpec::Coverage.report! }

# Encoding: utf-8

require_relative 'spec_helper'

describe file('/tmp/xmledit_edit_test.xml') do
  it { should be_file }

  [
    %r{<bar>xyzzy</bar>},
    %r{<baz>true</baz>},
    %r{<showme/>}
  ].each do |r|
    its(:content) { should match(r) }
  end

  its(:content) { should_not match(/hideme/)}
end

describe file('/tmp/xmledit_bulk_test.xml') do
  it { should be_file }

  [
    %r{<bar>xyzzy</bar>},
    %r{<baz>true</baz>},
    %r{<showme/>}
  ].each do |r|
    its(:content) { should match(r) }
  end

  its(:content) { should_not match(/hideme/)}
end

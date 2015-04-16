include_recipe 'xmledit::default'

File.open('/tmp/xmledit_edit_test.xml', 'w') do |file|
  file.write("<foo><bar>true</bar><hideme/></foo>")
end

xml_edit 'bar should be xyzzy' do
  path '/tmp/xmledit_edit_test.xml'
  target '/foo/bar'
  fragment '<bar>xyzzy</bar>'
  action :replace
end

xml_edit 'add baz' do
  path '/tmp/xmledit_edit_test.xml'
  parent '/foo'
  target '/foo/baz'
  fragment '<baz>true</baz>'
  action :append
end

xml_edit 'remove hideme' do
  path '/tmp/xmledit_edit_test.xml'
  target '/foo/hideme'
  action :remove
end

xml_edit 'add showme' do
  path '/tmp/xmledit_edit_test.xml'
  parent '/foo'
  target '/foo/showme'
  fragment '<showme/>'
  action :append_if_missing
end

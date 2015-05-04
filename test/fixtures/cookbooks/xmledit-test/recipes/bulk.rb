include_recipe 'xmledit::default'

File.open('/tmp/xmledit_bulk_test.xml', 'w') do |file|
  file.write("<foo><bar>true</bar><hideme/></foo>")
end

xml_edit '/tmp/xmledit_bulk_test.xml' do
  edits [
    {action: :replace, target: '/foo/bar', fragment: '<bar>xyzzy</bar>'},
    {action: :append, parent: '/foo', target: '/foo/baz', fragment: '<baz>true</baz>'},
    {action: :remove, target: '/foo/hideme'},
    {action: :append_if_missing, parent: '/foo', target: '/foo/showme', fragment: '<showme/>'}
    ]
  action :bulk
end

include_recipe 'xmledit-test::default'

File.open('/tmp/idempotent_same.xml', 'w') { |file| file.write("<?xml version=\"1.0\"?>\n<foo>\n  <bar>true</bar>\n</foo>\n") }

xml_edit 'bar should already be true' do
  path '/tmp/idempotent_same.xml'
  target '/foo/bar'
  fragment '<bar>true</bar>'
  action :replace
end

File.open('/tmp/idempotent_changed.xml', 'w') { |file| file.write("<?xml version=\"1.0\"?>\n<foo>\n  <bar>false</bar>\n</foo>\n") }

xml_edit 'change bar to true' do
  path '/tmp/idempotent_changed.xml'
  target '/foo/bar'
  fragment '<bar>true</bar>'
  action :replace
end

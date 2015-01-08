# cookbook/libraries/matchers.rb

if defined?(ChefSpec)
  def replace_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xml_edit, :replace, resource_name)
  end

  def append_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xml_edit, :append, resource_name)
  end


  def remove_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xml_edit, :remove, resource_name)
  end

  def append_if_missing_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xml_edit, :append_if_missing, resource_name)
  end
end

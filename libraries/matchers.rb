# cookbook/libraries/matchers.rb

if defined?(ChefSpec)
  def replace_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xmledit, :replace, resource_name)
  end

  def append_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xmledit, :append, resource_name)
  end


  def remove_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xmledit, :remove, resource_name)
  end

  def append_if_missing_xml(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:xmledit, :append_if_missing, resource_name)
  end
end

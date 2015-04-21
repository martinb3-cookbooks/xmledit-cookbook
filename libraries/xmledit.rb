class Chef
  class Resource::XmlEdit < Resource
    include Poise

    # see README.md for documentation on these actions
    # first action is the default, by convention
    actions(:replace, :append, :remove, :append_if_missing)

    # see README.md for documentation on these attributes
    attribute(:path, kind_of: String, default: nil)
    attribute(:target, kind_of: String, default: nil)
    attribute(:parent, kind_of: String, default: nil)
    attribute(:fragment, kind_of: String, default: nil)

    attribute(:bind_root_namespace, kind_of: [ TrueClass, FalseClass ], default: true)
  end

  class Provider::XmlEdit < Provider
    include Poise

    # we can't really do whyrun when we only have action methods; by the time an
    # action is called, we're assuming we're doing something.
    def whyrun_supported?
      true
    end

    def action_replace
        # load existing file
        doc = load_xml_file(new_resource.path)

        # parse given fragment
        fragment = build_fragment(new_resource.fragment)

        # find target
        node_to_replace = doc.at_xpath(new_resource.target, (new_resource.bind_root_namespace) ? doc.root.namespaces : {}) 
        unless node_to_replace
          # nil means the node wasn't found, so no-op here
          return
        end

        # replace target with new fragment
        node_to_replace.replace(fragment)

        # new file contents
        new_file_contents = document_to_string(doc)
        file_to_write = new_resource.path
        resource_name = new_resource.name
        old_file_contents = ::File.open(new_resource.path).read

        # write new file
        resource = file resource_name do
          path file_to_write
          content new_file_contents
          action :nothing
        end

        resource.run_action(:create)
        new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
        warn_if_resource_update_looks_wrong(old_file_contents, new_file_contents, resource.updated_by_last_action?)
    end

    def action_append
      # load existing file
      doc = load_xml_file(new_resource.path)

      # parse given fragment
      fragment = build_fragment(new_resource.fragment)

      # find target
      node_parent = doc.at_xpath(new_resource.parent, (new_resource.bind_root_namespace) ? doc.root.namespaces : {})
      unless node_parent
        # nil means the node wasn't found, so no-op here
        return
      end

      # add fragment to parent
      node_parent.add_child(fragment)

      # new file contents
      new_file_contents = document_to_string(doc)
      file_to_write = new_resource.path
      resource_name = new_resource.name
      old_file_contents = ::File.open(new_resource.path).read

      # write new file
      resource = file resource_name do
        path file_to_write
        content new_file_contents
        action :nothing
      end

      resource.run_action(:create)
      new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
      warn_if_resource_update_looks_wrong(old_file_contents, new_file_contents, resource.updated_by_last_action?)
    end

    def action_append_if_missing
      # load existing file
      doc = load_xml_file(new_resource.path)

      # parse given fragment
      fragment = build_fragment(new_resource.fragment)

      namespaces_to_bind = (new_resource.bind_root_namespace) ? doc.root.namespaces : {}

      # find target
      node_target = doc.at_xpath(new_resource.target, namespaces_to_bind)

      # find parent
      node_parent = doc.at_xpath(new_resource.parent, namespaces_to_bind)

      if node_target
        # found target, so we are replacing instead of adding
        node_target.replace(fragment)
      elsif node_parent
        # found parent but not target, so we are going to add
        node_parent.add_child(fragment)
      else
        # could not find target or parent
        return
      end

      # new file contents
      new_file_contents = document_to_string(doc)
      file_to_write = new_resource.path
      resource_name = new_resource.name
      old_file_contents = ::File.open(new_resource.path).read

      # write new file
      resource = file resource_name do
        path file_to_write
        content new_file_contents
        action :nothing
      end
      resource.run_action(:create)
      new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
      warn_if_resource_update_looks_wrong(old_file_contents, new_file_contents, resource.updated_by_last_action?)
    end

    def action_remove
      # load existing file
      doc = load_xml_file(new_resource.path)

      # find target
      node_to_remove = doc.at_xpath(new_resource.target, (new_resource.bind_root_namespace) ? doc.root.namespaces : {})
      unless node_to_remove
        # nil means the node wasn't found, so no-op here
        return
      end

      # remove target
      node_to_remove.remove

      # new file contents
      new_file_contents = document_to_string(doc)
      file_to_write = new_resource.path
      resource_name = new_resource.name
      old_file_contents = ::File.open(new_resource.path).read

      # write new file
      resource = file resource_name do
        path file_to_write
        content new_file_contents
        action :nothing
      end
      resource.run_action(:create)
      new_resource.updated_by_last_action(true) if resource.updated_by_last_action?
      warn_if_resource_update_looks_wrong(old_file_contents, new_file_contents, resource.updated_by_last_action?)
    end

    def load_xml_file(filename)
      require 'nokogiri'
      file_localxml = ::File.open(filename)
      doc_localxml = Nokogiri::XML(file_localxml, &:noblanks)
      file_localxml.close
      doc_localxml
    end

    def build_fragment(raw_text)
      require 'nokogiri'
      Nokogiri::XML::DocumentFragment.parse(raw_text, &:noblanks)
    end

    def document_to_string(document)
      require 'nokogiri'

      # this is a terrible solution to nokogiri's problem of only normalizing
      # certain parts of a document on ingest/parse, not on Node#to_xml.
      file = Tempfile.new('xmledit')
      begin
         ::File.write(file, document.to_xml)
         load_xml_file(file).to_xml
      ensure
         file.close
         file.unlink   # deletes the temp file
      end
    end

    def warn_if_resource_update_looks_wrong(old_file_contents, new_file_contents, resource_updated_by_last_action)
      if (old_file_contents != new_file_contents) && !resource_updated_by_last_action
        Chef::Log.warn("#{new_resource.name} file should have been changed, but updated_by_last_action? is false")
        Chef::Log.debug("#{new_resource.name} old: #{old_file_contents}")
        Chef::Log.debug("#{new_resource.name} new: #{new_file_contents}")
      elsif (old_file_contents == new_file_contents) && resource_updated_by_last_action
        Chef::Log.warn("#{new_resource.name} file should not have been changed, but updated_by_last_action? is true")
        Chef::Log.debug("#{new_resource.name} old: #{old_file_contents}")
        Chef::Log.debug("#{new_resource.name} new: #{new_file_contents}")
      end
    end

  end
end

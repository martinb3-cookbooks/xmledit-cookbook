class Chef
  class Resource::XmlEdit < Resource
    include Poise

    # see README.md for documentation on these actions
    # first action is the default, by convention
    actions(:replace, :append, :remove, :append_if_missing, :bulk)

    # see README.md for documentation on these attributes
    attribute(:path, kind_of: String, name_attribute: true)
    attribute(:target, kind_of: String, default: nil)
    attribute(:parent, kind_of: String, default: nil)
    attribute(:fragment, kind_of: String, default: nil)

    # for bulk edits, pass an array of hashes of the above items
    attribute(:edits, kind_of: Array, default: [])

    # for nokogiri's happiness
    attribute(:bind_root_namespace, kind_of: [TrueClass, FalseClass], default: true)
  end

  class Provider::XmlEdit < Provider
    include Poise
    include XmleditCookbook::Helpers

    def document
      # returns document, loading it if necessary
      unless @document
        # load existing file
        @document = load_xml_file(new_resource.path)
      end
      @document
    end

    def namespace
      if new_resource.bind_root_namespace
        document.root.namespaces
      else
        {}
      end
    end

    # we can't really do whyrun when we only have action methods; by the time an
    # action is called, we're assuming we're doing something.
    def whyrun_supported?
      true
    end

    def action_bulk
      make_edit(:bulk, new_resource.path, new_resource.target, new_resource.parent, new_resource.fragment)
      write_document
    end

    def _action_bulk(edits)
      unless edits || edits.empty?
        Chef::Log.warn("#{new_resource.name} was given no edits for :bulk action")
        return
      end

      edits.each do |edit|
        make_edit(edit[:action], edit[:path], edit[:target], edit[:parent], edit[:fragment])
      end
    end

    def action_replace
      make_edit(:replace, new_resource.path, new_resource.target, new_resource.parent, new_resource.fragment)
      write_document
    end

    def _action_replace(target, fragment)
      # parse given fragment
      fragment_xml = build_fragment(fragment)

      # find target
      node_to_replace = document.at_xpath(target, namespace)
      unless node_to_replace
        # nil means the node wasn't found, so no-op here
        return
      end

      # replace target with new fragment
      node_to_replace.replace(fragment_xml)
    end

    def action_append
      make_edit(:append, new_resource.path, new_resource.target, new_resource.parent, new_resource.fragment)
      write_document
    end

    def _action_append(parent, fragment)
      # parse given fragment
      fragment_xml = build_fragment(fragment)

      # find target
      node_parent = document.at_xpath(parent, namespace)
      unless node_parent
        # nil means the node wasn't found, so no-op here
        return
      end

      # add fragment to parent
      node_parent.add_child(fragment_xml)
    end

    def action_append_if_missing
      make_edit(:append_if_missing, new_resource.path, new_resource.target, new_resource.parent, new_resource.fragment)
      write_document
    end

    def _action_append_if_missing(_path, target, parent, fragment)
      # parse given fragment
      fragment_xml = build_fragment(fragment)

      # find target
      node_target = document.at_xpath(target, namespace)

      # find parent
      node_parent = document.at_xpath(parent, namespace)

      if node_target
        # found target, so we are replacing instead of adding
        node_target.replace(fragment_xml)
      elsif node_parent
        # found parent but not target, so we are going to add
        node_parent.add_child(fragment_xml)
      else
        # could not find target or parent
        return
      end
    end

    def action_remove
      make_edit(:remove, new_resource.path, new_resource.target, new_resource.parent, new_resource.fragment)
      write_document
    end

    def _action_remove(target)
      # find target
      node_to_remove = document.at_xpath(target, namespace)
      unless node_to_remove
        # nil means the node wasn't found, so no-op here
        return
      end

      # remove target
      node_to_remove.remove
    end

    def make_edit(action, path, target, parent, fragment)
      case action
      when :remove
        _action_remove(target)
      when :append_if_missing
        _action_append_if_missing(path, target, parent, fragment)
      when :append
        _action_append(parent, fragment)
      when :replace
        _action_replace(target, fragment)
      when :bulk
        _action_bulk(new_resource.edits)
      else
        fail "#{action} was not a valid action for #{new_resource.name}"
      end
    end

    def write_document
      old_file_contents = ::File.open(new_resource.path).read
      new_file_contents = document_to_string(document)

      file_to_write = new_resource.path
      resource_name = new_resource.name

      # write new file
      resource = file resource_name do
        path file_to_write
        content new_file_contents
        action :nothing
      end

      resource.run_action(:create)
      new_resource.updated_by_last_action(true) if resource.updated_by_last_action?

      warn_if_resource_update_looks_wrong(new_resource.name, old_file_contents, new_file_contents, resource.updated_by_last_action?)
    end
  end
end

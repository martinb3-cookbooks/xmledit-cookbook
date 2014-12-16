class Chef
  class Resource::XmlEdit < Resource
    include Poise

    # first action is the default, by convention
    # - replace updates a target (and all children)
    # - append inserts a child node to a target parent
    # - remove gets rid of a target node
    actions(:replace, :append, :remove)

    # the XML file we plan to modify
    attribute(:path, kind_of: String, default: nil)

    # XPath expression for where to operate on the document
    #  - For action insert, should be parent of node to be inserted
    #  - For action cut, should be the node to remove
    attribute(:target, kind_of: String, default: nil)

    # An xml fragment that will be parsed and applied to the action
    #  - For action insert, this fragment will be pasted in as a child of the target attribute
    #  - For action remove, this attribute has no effect
    attribute(:fragment, kind_of: String, default: nil)
  end

  class Provider::XmlEdit < Provider
    include Poise

    def action_replace
      converge_by("replace resource #{new_resource.name}") do
        # load existing file
        doc = load_xml_file(new_resource.path)

        # parse given fragment
        fragment = build_fragment(new_resource.fragment)

        # find target
        node_to_replace = doc.at_xpath(new_resource.target)
        unless node_to_replace
          # nil means the node wasn't found, so no-op here
          new_resource.updated_by_last_action(false)
          return
        end

        # replace target with new fragment
        node_to_replace.replace(fragment)

        # new file contents
        new_file_contents = doc.to_xml
        file_to_write = new_resource.path
        resource_name = new_resource.name

        notifying_block do
          # write new file
          file resource_name do
            path file_to_write
            content new_file_contents
          end
        end
      end
    end

    def action_append
      converge_by("append from resource #{new_resource.name}") do
        notifying_block do
          # load existing file
          doc = load_xml_file(new_resource.path)

          # parse given fragment
          fragment = build_fragment(new_resource.fragment)

          # find target
          node_parent_to_append = doc.at_xpath(new_resource.target)
          unless node_parent_to_append
            # nil means the node wasn't found, so no-op here
            new_resource.updated_by_last_action(false)
            return
          end

          # replace target with new fragment
          node_parent_to_append.add_child(fragment)

          # new file contents
          new_file_contents = doc.to_xml
          file_to_write = new_resource.path
          resource_name = new_resource.name

          notifying_block do
            # write new file
            file resource_name do
              path file_to_write
              content new_file_contents
            end
          end
        end
      end
    end

    def action_remove
      converge_by("remove from resource #{new_resource.name}") do
        # load existing file
        doc = load_xml_file(new_resource.path)

        # parse given fragment
        fragment = build_fragment(new_resource.fragment)

        # find target
        node_to_remove = doc.at_xpath(new_resource.target)
        unless node_to_remove
          # nil means the node wasn't found, so no-op here
          new_resource.updated_by_last_action(false)
          return
        end

        # remove target
        node_to_remove.remove(fragment)

        # new file contents
        new_file_contents = doc.to_xml
        file_to_write = new_resource.path
        resource_name = new_resource.name

        notifying_block do
          # write new file
          file resource_name do
            path file_to_write
            content new_file_contents
          end
        end
      end
    end

    def load_xml_file(filename)
      require 'nokogiri'
      file_localxml = ::File.open(filename)
      doc_localxml = Nokogiri::XML(file_localxml)
      file_localxml.close
      doc_localxml
    end

    def build_fragment(raw_text)
      require 'nokogiri'
      Nokogiri::XML::DocumentFragment.parse(raw_text)
    end

  end
end

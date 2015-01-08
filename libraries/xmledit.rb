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
        new_file_contents = document_to_string(doc)
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
          node_parent = doc.at_xpath(new_resource.parent)
          unless node_parent
            # nil means the node wasn't found, so no-op here
            new_resource.updated_by_last_action(false)
            return
          end

          # add fragment to parent
          node_parent.add_child(fragment)

          # new file contents
          new_file_contents = document_to_string(doc)
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

    def action_append_if_missing
      converge_by("append if missing from resource #{new_resource.name}") do
        notifying_block do
          # load existing file
          doc = load_xml_file(new_resource.path)

          # parse given fragment
          fragment = build_fragment(new_resource.fragment)

          # find target
          node_target = doc.at_xpath(new_resource.target)

          # find parent
          node_parent = doc.at_xpath(new_resource.parent)

          if node_target
            # found target, so we are replacing instead of adding
            node_target.replace(fragment)
          elsif node_parent
            # found parent but not target, so we are going to add
            node_parent.add_child(fragment)
          else
            # could not find target or parent
            new_resource.updated_by_last_action(false)
            return
          end


          # new file contents
          new_file_contents = document_to_string(doc)
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

        # find target
        node_to_remove = doc.at_xpath(new_resource.target)
        unless node_to_remove
          # nil means the node wasn't found, so no-op here
          new_resource.updated_by_last_action(false)
          return
        end

        # remove target
        node_to_remove.remove

        # new file contents
        new_file_contents = document_to_string(doc)
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
      document.to_xml(:indent => 2)
    end

  end
end

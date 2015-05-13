module XmleditCookbook
  module Helpers
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

    def warn_if_resource_update_looks_wrong(name, old_file_contents, new_file_contents, resource_updated_by_last_action)
      if (old_file_contents != new_file_contents) && !resource_updated_by_last_action
        Chef::Log.warn("#{name} file should have been changed, but updated_by_last_action? is false")
        Chef::Log.debug("#{name} old: #{old_file_contents}")
        Chef::Log.debug("#{name} new: #{new_file_contents}")
      elsif (old_file_contents == new_file_contents) && resource_updated_by_last_action
        Chef::Log.warn("#{name} file should not have been changed, but updated_by_last_action? is true")
        Chef::Log.debug("#{name} old: #{old_file_contents}")
        Chef::Log.debug("#{name} new: #{new_file_contents}")
      elsif document_to_string(build_fragment(old_file_contents)) == document_to_string(build_fragment(new_file_contents)) && resource_updated_by_last_action
        Chef::Log.warn("#{name} file was updated but DOM appears to be equivalent")
        Chef::Log.debug("#{name} old: #{old_file_contents}")
        Chef::Log.debug("#{name} new: #{new_file_contents}")
      end
    end
  end
end

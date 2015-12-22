class Chef
  class Resource
    class XmlEdit < Chef::Resource::LWRPBase
      provides :xml_edit

      # see README.md for documentation on these actions
      # first action is the default, by convention
      actions :replace, :append, :remove, :append_if_missing, :bulk
      default_action :replace

      # see README.md for documentation on these attributes
      attribute :path, kind_of: String, name_attribute: true
      attribute :target, kind_of: String, default: nil
      attribute :parent, kind_of: String, default: nil
      attribute :fragment, kind_of: String, default: nil

      # for bulk edits, pass an array of hashes of the above items
      attribute :edits, kind_of: Array, default: []

      # for nokogiri's happiness
      attribute :bind_root_namespace, kind_of: [TrueClass, FalseClass], default: true
    end
  end
end

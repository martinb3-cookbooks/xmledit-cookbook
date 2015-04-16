# 1.0.6

- Remove metadata that breaks chef 11 (source and issue url metadata, specifically)
- Add more unit tests and integration tests
- Update logic so that xml_edit resource truly reflects the state of the file resource being updated

# 1.0.5

- Do not parse a fragment or try to pass :remove action the fragment

# 1.0.1

- Add the ability to replace or append (action append_if_missing)
- Attempt to strip/format whitespace better when editing

# 1.0.0

- Rename actions to map better to nokogiri operations
- Implement remove and append actions
- Add missing xml cookbook dependency

# 0.1.0

- Initial release.

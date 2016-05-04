# 3.0.3

- Add ability to prepend when doing an append, vs. adding at the end

# 3.0.2

- Tweak name of matcher

# 3.0.1

- Add a bulk edit matcher

# 3.0.0

- Start using `provides`, breaks Chef 11 compat (#11)
- Update CentOS testing from 6.6 to 6.7
- Update Berkshelf pin to ~> 4
- New rubocop complaints addressed

# 2.0.0

- Remove poise dependency, bump to v2.0.0 (#10)

# 1.2.4

- Close all file handles (#11)

# 1.2.3

- Ensure we pin to latest poise, so Berkshelf does not use xmledit with older poise

# 1.2.2

- Make compatible with poise 2.0 by adding `require 'poise'` to each resource and provider class.

# 1.2.1

- Remove comment that was preventing updates ot the file, fixes #9.

# 1.2.0

- New feature: bulk action with associated `edits` attribute. Pass an array of hashes that describe each edit, using the same parameters as the other actions. See README.md for an example.

# 1.1.0

- Load namespace in Nokogiri calls (#7)

# 1.0.7

- Normalize the output of modified XML. Nokogiri seems to be better at parsing files into normalized XML than just writing it out, so we added a very unfortunate temporary file workaround.

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

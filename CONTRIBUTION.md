# How to Contribute
## Things we will merge
- Bug fixes
- Performance improvements
- Features which are likely to be useful to the majority of users

## Things we won't merge
- Code which adds no significant value to the library
- Code which comes without tests
- Code which breaks existing tests

## Workflow
1. Fork it ( https://github.com/shopify/buildkit/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

Please keep the following in mind:

Add a short entry to the "unreleased" section in [RedirectSafely](./RedirectSafely) describing your changes.
Do not change RedirectSafely::VERSION; this is done as part of the release process.

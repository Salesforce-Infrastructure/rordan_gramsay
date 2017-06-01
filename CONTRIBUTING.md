# Contributing

Here is a short checklist of what we strive for in a well-formed code contribution:

- [ ] Automated tests are written for new/modified features
- [ ] All automated tests are passing
- [ ] Commit log is clean and devoid of "debugging" types of commits
- [ ] Entry into [CHANGELOG.md](/CHANGELOG.md) with `(credit: @username)` (see **Changelog** above)
- [ ] Pull request is associated with at least 1 issue

Do your best to check as many of these boxes as you can and everything will be fine!

## Issues

Any bugs you find, features you want to request, or questions you have should go in the
repository's [issues section](https://github.com/Salesforce-Infrastructure/rordan_gramsay/issues).
Please, be kind and search through the open and closed issues to make sure your question
or bug report hasn't already been posted and resolved.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also
run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release
a new version, update the version number in `version.rb`, and then run `bundle exec rake
release`, which will create a git tag for the version, push git commits and tags, and
push the `.gem` file to the private rubygems server (which currently fails).

## Testing

This project has automated tests coverage (usually between 80% and 90%), so checking
whether current tests pass is a reliable way of checking if your changes break backward
compatibility. To run them, execute `bundle exec rake spec` or `bundle exec rspec`.

To write high quality rspec tests, consider the [Better Specs guidelines](http://www.betterspecs.org/).

If you're still not quite sure what to do, feel free to open a pull request with `[WIP]`
in the title of it to get some help. See below for more details on the `[WIP]` convention.

## Pull requests

If you're unfamiliar with the process, see [Github's helpful documentation](https://help.github.com/articles/about-pull-requests/)
on creating pull requests.

We try to keep a parity of at least one issue being opened for any pull request. While not
a hard requirement, this encourages discussion before development occurs to keep any wasted
time to a minimum.

Additionally, if you are working on something and would like some periodic feedback (which
is recommended for large changes), it is recommended to open a pull request with the title
prepended with `[WIP]`. For example, restructuring a project from using MongoDB to Cassandra
might look like the following:

```
TITLE: [WIP] Convert from MongoDB to Cassandra

Some description here

- [ ] To do list item
- [ ] Other to do list item
- [x] Completed to do list item

I'm looking for feedback on what I've added so far.
```

## Changelog

We also follow the practices defined on [Keep A Changelog](http://keepachangelog.com), keeping
our changelog in [`CHANGELOG.md`](/CHANGELOG.md).

The gist of it is:

- Add line items with very short summary of changes to `CHANGELOG.md` under the `UNRELEASED` section as they are created
- Add `(credit: @your_username)` at the end of each line-item added
- Replace `UNRELEASED` section title with the version number on release, then create a new header above it named `UNRELEASED`

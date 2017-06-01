# Rordan Gramsay

This is a toolset our team uses to develop higher quality Chef cookbooks. The bar is
intentionally set high so that good practices become second nature during development.

We draw much of our inspiration from our cooking themed tools in Chef and found the king
of Hell's Kitchen, Gordon Ramsay, seemed a fitting name for a tool so picky about quality.

## Use case

The primary goal is to keep a consistent set of tools across all of our cookbooks for
running tests and checking for code quality. The problem with throwing all of this into
a Rakefile for each project is that our decided best-practices may change, or we fix bugs
in how we're checking for quality in the source files, or any number of other things may
change.

What happens when we make those changes? We have to go through each and every cookbook to
update the Rakefile to the latest version. Some would be missed (or partially updated),
and it quickly becomes a nightmare to maintain.

By compiling all of these practices into a gem, we can reference it from the Rakefile and
much more easily keep it up-to-date. Now the best practices codified in the Rakefile are
no longer versioned with the cookbook itself.

## Installation

For most uses, this gem should be installed and used globally.

Recommended installation is via rubygems.org:

```
$ gem install rordan_gramsay
# => Successfully installed rordan_gramsay-0.4.0
# => 1 gem installed
```

Or download the [latest release from Github](https://github.com/Salesforce-Infrastructure/rordan_gramsay/releases/latest) and install locally:

```
$ gem uninstall rordan_gramsay -v 0.4.0
# => Successfully uninstalled rordan_gramsay-0.4.0
$ gem install ~/Downloads/rordan_gramsay-v0.4.0.gem
# => Successfully installed rordan_gramsay-0.4.0
# => 1 gem installed
```

For the rare case when you might need this inside of Bundler, add this line to your
application's Gemfile:

```ruby
gem 'rordan_gramsay'
```

And then execute:

```
$ bundle install
# => Using rake 12.0.0
# => Using paint 2.0.0
# => Using bundler 1.14.6
# => Using rordan_gramsay 0.4.0
# => Bundle complete! 1 Gemfile dependency, 4 gems now installed.
# => Use `bundle show [gemname]` to see where a bundled gem is installed.
```

## Usage

There are a few options to add this to your recipe. Each part of functionality is broken
into groups for easier control.

You will need to include this in your Rakefile located in each recipe directory. Commonly
this will be a full test, but there are options to use only a smaller set of tests if you
choose.

### Full cookbook testing (usually what you want as this is the gate to production)

For an individual cookbook repository, include a Rakefile with the following contents:

```ruby
require 'rordan_gramsay/chef_tasks/lint'
require 'rordan_gramsay/chef_tasks/kitchen'
require 'rordan_gramsay/chef_tasks/test'

task default: ['test:all']
```

This will provide the following testing options from the command line:

```
$ rake -T

  rake kitchen  # Runs integration tests using Test Kitchen
  rake lint     # Lints cookbook using all tools
  rake test     # Runs all linting and integration tests
```

For a monolithic repo style of cookbook tracking, see the **Recursive testing** section below.

### Lint testing only

Include the following contents in your Rakefile:

```ruby
require 'rordan_gramsay/chef_tasks/lint'

task default: ['lint:all']
```

This will provide the following testing options from the command line:

```
$ rake -T

  rake lint  # Lints cookbook using all tools
```

### Recursive testing

For a monolithic repository situation, where multiple cookbooks are stored in the
`cookbooks/` directory relative to the project root, there is a set of rake tasks to
handle this mass testing. Add the following to a Rakefile in the monolithic repo root
directory:

```ruby
require 'rordan_gramsay/chef_tasks/master_repo'
```

This will provide the following testing options from the command line:

```
$ rake -T

  rake lint  # Runs linting, style checks, and overall formatting checks for each cookbook
  rake test  # Runs all linting and tests on all cookbooks
```

In order to make use of this, each cookbook repo must also implement the tasks defined
in the cookbook Rakefiles.

## Contributing

See [CONTRIBUTING.md](/CONTRIBUTING.md).

## License

See [LICENSE.txt](/LICENSE.txt).

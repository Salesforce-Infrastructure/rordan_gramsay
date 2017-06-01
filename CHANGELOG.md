# Changelog

We follow [Semantic Versioning](http://semver.org/) as a way of measuring stability of an update. This
means we will never make a backwards-incompatible change within a major version of the project.

## _[UNRELEASED]_

No changes so far...

## v0.5.0

- Added automated test support for CLI generating Rakefiles
- Changed CLI docs to mention the correct executable (`sfmc-tool` -> `gordon-ramsay`)
- Added basic integration tests for all rake tasks
- Added full integration tests for custom linting rake tasks
- Added unit tests for custom linting rake tasks
- Extracted custom linting rake tasks into separate objects (easier to test)
- Extended failure messages of custom linting rake tasks with reasons why they failed, per file
- Added summary of number of files needed to be fixed only when failures occur in custom linting rake tasks
- **[BREAKING]** Inspec test linter now checks for `describe` blocks instead of `encoding: utf-8` string
- **[BUG]** Inspec test linter detects and adjusts rules for if nested Inspec profile (only checks `controls/` for tests if finding `inspec.yml` in directory)

## v0.4.0

- Significant docs updates
- Removes `rake -T` listing for many subtasks (e.g., no more description for `rake lint:rubocop`)
- Mono-repo Rakefile defers completely to nested cookbook's Rakefile tasks
- **[BREAKING]** Mono-repo's `rake test` alias changed from `rake test:quick` to `rake test:all`
- **[BUG]** Fork-bomb from mono-repo if nested cookbook does not have any Rakefile defined (lays down a Rakefile using CLI if none is there)
- **[BUG]** `rake kitchen:test` should only be defined once, and run once

## v0.3.1

- **[BUG]** Non-working `term-ansicolor` gem was replaced with `paint`
- **[BUG]** `rake lint:all` on mono-repo should not run `rake kitchen:test` on nested cookbooks
- **[BUG]** Inconsistent docs for how to initialize a Rakefile for mono-repo via the CLI

## v0.3.0

- Renamed gem from `SFMCTools` to `GordonRamsay`

## v0.2.2

- **[BUG]** Parallel execution of tests on mono-repo was not working as expected. Queued exactly 1 process fork before blocking until it was complete

## v0.2.1

- **[BUG]** `rake release` should not push to Rubygems.org
- **[BUG]** Checking if tests are written failed on passing condition and vice versa
- **[BUG]** Checking for comments produced a fail only when a comment existed on _any_ of the first 5 lines (expected: pass if on _all_ of the first 5 lines)
- **[BUG]** Checking for `inspec` in the `.kitchen.yml` incorrectly limited to the first 5 lines of the file
- **[BUG]** Mirrors mono-repo task `rake test:all` into cookbook tasks `rake test:all`

## v0.2.0

- Adds CLI tool to lay down default Rakefiles for cookbook development and monolithic repo

## v0.1.1

- Fixes overly strict dependency on Rake v10.x

## v0.1.0

- Initial release
- Rakefile for cookbook development
- Rakefile for monolithic repo management

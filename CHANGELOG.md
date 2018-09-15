# Changelog

We follow [Semantic Versioning](http://semver.org/) as a way of measuring stability of an update. This
means we will never make a backwards-incompatible change within a major version of the project.

## v1.4.0 (2018-09-15)

- Adds Simplecov for measuring test coverage
- Increases test coverage
- [BUG] Spelling inconsistencies (`Pass` -> `Passed`, `Fail` -> `Failed`, `Foodcritic` -> `FoodCritic`)
- Centralizes generating test data for a cookbook (or monolithic repository) to one spot
- Fixes tons of rubocop errors
- [BUG] Undeclared dependency: `foodcritic`
- Upgrades dependencies to be based on what is available as part of ChefDK v3.1.0
- [BUG] Processes `*.rb` files in non-profile InSpec directory, when InSpec only processes `*_test.rb`
- Adds support for detecting BSD licenses
- Supports reading `.foodcritic` file for rule skips

## v1.3.2 (2017-06-08)

- [BUG] Support 'All Rights Reserved' license

## v1.3.1 (2017-06-08)

- [BUG] Rubocop linting task didn't actually run Rubocop

## v1.3.0 (2017-06-08)

- Ignore FoodCritic rule FC078, requiring open source licenses only

## v1.2.0 (2017-06-08)

- List a summary of FoodCritic rules broken with code and name after listing of files
- `RordanGramsay::Foodcritic::RuleList` rules are sorted by code

## v1.1.2 (2017-06-08)

- [BUG] Rake task for FoodCritic used `String#format`, which is a private method in Ruby

## v1.1.1 (2017-06-08)

- [BUG] Rake task for FoodCritic counted the failures based on an old object structure
- `RordanGramsay::Foodcritic::FileList#each` acts like iterating over array instead of a hash

## v1.1.0 (2017-06-08)

- [BUG] Foodcritic linting task should actually output results
- Foodcritic output is displayed by file/line instead of by rule
- Suppresses warnings for FoodCritic gem internals

## v1.0.1 (2017-06-01)

- Corrects fork-bomb problem if rake tasks are run from mono-repo and any cookbooks don't have a Rakefile

## v1.0.0 (2017-06-01)

- Initial release
- Rakefile for cookbook development
- Rakefile for monolithic repo management
- Custom linting for Test Kitchen's `.kitchen.yml` contents
- Custom linting for comment lines at top of certain files
- Custom linting to ensure tests are written
- Linting via Foodcritic
- Linting via Rubocop / Cookstyle
- Test Kitchen commands as rake tasks

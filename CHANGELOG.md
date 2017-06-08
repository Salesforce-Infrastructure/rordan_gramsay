# Changelog

We follow [Semantic Versioning](http://semver.org/) as a way of measuring stability of an update. This
means we will never make a backwards-incompatible change within a major version of the project.

## _[UNRELEASED]_

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

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2020-12-15
### Changed
- add `0x` to signature to be compatible with JS and not throw `signature missing v and recoveryParam` error

## [0.0.4] - 2020-11-26
### Added
- `generate_sso_request_params` throws on empty PK

### Changed
- join operator for `message_to_sign` is now `&`
- `message_to_sign` ignores data that are not set

### Fixed
- ensure testing `throws` is working correctly
- rubocop offences

## [0.0.3] - 2020-11-25
### Added
- Logo and badges to README

## [0.0.2] 2020-11-23
### Added
- add support for `redirectMethod`

### Changed
- `generate_sso_request_params` raises error when missing required params

### Removed
- html doc files from repo

## [0.0.1] 2020-11-20
### Added:
- initial version

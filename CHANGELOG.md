## [1.4.3] - 2018-06-11

### Fixed

  - arkadiybutermanov introduced safer CVE fix. Sinatra should not have been upgraded as part of a patch release either.

## [1.4.2] - 2018-05-31

### Fixed
  - Merge fixes for 2 security issues. CVE-2018-7212, CVE-2017-12097

## [1.4] - 2017-05-02

### Added
  - Feature: Make the "enqueue all" button optional
  - Feature: Add `per_page` param to specify number of jobs per page

## [1.3] - 2017-04-21

### Added
  - Feature: show number of jobs per queue in Overview
  - Feature: search jobs based on handler

### Fixed
  - Bug: Fix run at "relatize_date" inaccuracy
  - Documentation: how to authenticate with Devise
  - Documentation: replace timing attack prone sample auth code 

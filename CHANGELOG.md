# Changelog

## [0.0.5]
### Added
- Dynamic width and alignment of the overlay with a 3-pixel vertical offset.
- Smooth fade and slide animations for the overlay appearance and dismissal.
- Automatic overlay hiding when the search input is cleared or the clear button is pressed.
- Fixed re-selection behavior to prevent the same prediction from triggering the overlay again.

## [0.0.4]
### Improved
- Optimized the overlay insertion logic to ensure smooth animations.
- Managed focus more effectively when interacting with the overlay.
- Enhanced state management to prevent redundant calls during input changes.

## [0.0.3]
### Added
- Dynamic width and alignment of the overlay with a 3-pixel vertical offset.
- Smooth fade and slide animations for the overlay appearance and dismissal.
- Automatic overlay hiding when the search input is cleared or the clear button is pressed.

## [0.0.2]
### Fixed
- Addressed overlay context issue by properly managing `AnimationController` with `SingleTickerProviderStateMixin`.
- Improved error handling for Google Maps API requests.
- Ensured that suffix icons reflect the correct input state.

## [0.0.1]
### Added
- Initial release of the Search Map package.
- Integrated Google Maps autocomplete and place details retrieval.
- Basic text field with search predictions in an overlay.
- Debounced search to reduce redundant API calls.
- Support for `easy_localization` to handle multi-language apps.

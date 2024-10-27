# Changelog

## [0.0.3] - 2024-10-27
### Added
- Dynamic width and alignment of the overlay with a 3-pixel vertical offset.
- Smooth fade and slide animations for the overlay appearance and dismissal.
- Automatic overlay hiding when the search input is cleared or the clear button is pressed.

## [0.0.2] - 2024-10-25
### Fixed
- Addressed overlay context issue by properly managing `AnimationController` with `SingleTickerProviderStateMixin`.
- Improved error handling for Google Maps API requests.

## [0.0.1] - 2024-10-20
### Added
- Initial release of the Search Map package.
- Integrated Google Maps autocomplete and place details retrieval.
- Basic text field with search predictions in an overlay.
- Debounced search to reduce redundant API calls.
- Support for `easy_localization` to handle multi-language apps.

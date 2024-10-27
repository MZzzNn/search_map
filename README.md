# Flutter Search Map

A **Flutter package** that integrates with the **Google Maps Places API** to provide a location search field with **autocomplete** and **place details** retrieval. This package simplifies adding map-based search functionality with a smooth **animated overlay** displaying predictions and handling user interactions seamlessly.

---

## Key Features

- **Google Places Autocomplete**: Get real-time suggestions for addresses.
- **Place Details Retrieval**: Fetch detailed information (name, address, coordinates) for any selected place.
- **Smooth Animated Overlay**: Search results appear and disappear with smooth **fade and slide animations**.
- **Debounce Search**: Reduce redundant API calls with built-in debouncing.
- **Dynamic Overlay Width**: The overlay matches the text field's width with a 3-pixel vertical offset for perfect alignment.
- **Customizable Overlay and Icons**: Display search results dynamically with customization options and **Font Awesome** icons.
- **Localization Support**: Works with `easy_localization` to support multiple languages.
- **Clear Button with Overlay Management**: Automatically hides the overlay when the search is cleared.
- **Session Management**: Manages API sessions efficiently to optimize performance and minimize costs.

---

## Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dependencies: 
  search_map: anya
```

## Getting Started

1. Create a Google Cloud Project and enable the Places API.
2. Generate an API Key from the Google Cloud Console.
3. Add your API Key to the widget configuration.


## Usage

```dart
import 'package:search_map/search_map.dart';

void main() {
  runApp(MyApp());
}

import 'package:search_map/search_map.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Search Map Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchMap(
            apiKey: 'YOUR_API_KEY',
            focusNode: FocusNode(),
            onClickAddress: (placeDetails) {
              print('Selected: ${placeDetails.description}');
            },
          ),
        ),
      ),
    );
  }
}
```

## Customization

- **Customize the overlay style**: Use the `overlayStyle` parameter to customize the overlay appearance.
- **Localization**: Use `easy_localization` to support multiple languages.
- **Debounce Time**: Adjust the debounce time with `debounceTime` to balance performance and responsiveness.
- **Icon Integration**: Use `font_awesome_flutter` for search icons.
- **Session Management**: Use `sessionManager` to manage API sessions efficiently.
- **Error Handling**: Handle errors gracefully using `onError` callback.
- **Customization**: Customize the overlay style, localization, debounce time, icon integration, session management, and
  error handling.
- **Localization**: Use `easy_localization` to support multiple languages.


## Contributing

Contributions are welcome! Please follow the [MZzzNn](https://github.com/MZzzNn) guidelines.

## License

This project is licensed under the [MIT License](LICENSE).
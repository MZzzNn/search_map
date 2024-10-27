import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:search_map/search_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: Scaffold(
        appBar: AppBar(title: Text('Search Map Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchMap(
            apiKey: 'YOUR_API_KEY',
            focusNode: FocusNode(),
            onClickAddress: (placeDetails) {
              print('Selected Place: ${placeDetails.toJson()}');
            },
          ),
        ),
      ),
    );
  }
}
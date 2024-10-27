import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:search_map/search_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('es'), Locale('ar')],
      path: 'assets/langs',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Map Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchMap(
            apiKey: 'YOUR_API_KEY',
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Search for a location',
            ),
            onClickAddress: (placeDetails) {
              print('Selected Place: ${placeDetails.toJson()}');
              focusNode.unfocus();
            },
          ),
        ),
      ),
    );
  }
}

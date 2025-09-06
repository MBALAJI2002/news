import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../features/news/presentation/providers/news_provider.dart';
import '../features/news/presentation/pages/feed_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NewsProvider(ApiClient(), pageSize: 20),
        ),
      ],
      child: MaterialApp(
        title: 'Balcode News',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const FeedPage(),
      ),
    );
  }
}

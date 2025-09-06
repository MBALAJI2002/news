import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    // Trigger the first load after the first frame so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchNextPage();
    });

    // Infinite scroll: when we're near the bottom, ask for the next page
    _controller.addListener(() {
      final provider = context.read<NewsProvider>();
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200 &&
          provider.status != NewsStatus.loading &&
          provider.status != NewsStatus.refreshing &&
          provider.hasMore) {
        provider.fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balcode News')),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          // First page loader
          if (provider.status == NewsStatus.loading && provider.page == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (provider.status == NewsStatus.failure && provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.errorMessage ?? 'Failed to load news'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.fetchNextPage(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty success
          if (provider.status == NewsStatus.success && provider.items.isEmpty) {
            return const Center(child: Text('No articles found'));
          }

          // Success / Refreshing
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount:
              provider.hasMore ? provider.items.length + 1 : provider.items.length,
              itemBuilder: (context, index) {
                // Footer loader while appending
                if (index >= provider.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final Article a = provider.items[index];
                final bool isLive = a.type.toLowerCase() == 'liveblog';
                final String when =
                DateFormat.yMMMd().add_jm().format(a.webPublicationDate.toLocal());
                final String subtitle = '${a.sectionName} • $when';

                return ListTile(
                  leading: isLive
                      ? Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : const Icon(Icons.article_outlined, size: 28),
                  title: Text(a.webTitle),
                  subtitle: Text(subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openArticle(a.webUrl),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

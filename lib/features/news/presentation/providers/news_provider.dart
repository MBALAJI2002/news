import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/article.dart';

enum NewsStatus { initial, loading, success, failure, refreshing }

class NewsProvider extends ChangeNotifier {
  final ApiClient api;                // HTTP client (Dio wrapper)
  final int pageSize;                 // Number of items per page

  NewsStatus status = NewsStatus.initial; // UI state: initial/loading/success/...
  List<Article> items = <Article>[];      // Loaded articles to render in the list
  bool hasMore = true;                    // Can we load more pages?
  int page = 0;                           // Last successfully loaded page number
  String? section;                        // Optional section filter (e.g., "technology")
  String? errorMessage;                   // Optional error description

  NewsProvider(this.api, {this.pageSize = 20});

  Future<void> fetchNextPage() async {
    // If we already know there's no more, or we're doing first load and still success, bail out
    if (!hasMore && status == NewsStatus.success) return;

    final int nextPage = (page == 0) ? 1 : page + 1; // First load → page 1
    final bool isFirstPage = nextPage == 1;

    // For first page show a full-screen loader; while appending, keep success
    status = isFirstPage ? NewsStatus.loading : NewsStatus.success;
    notifyListeners();

    try {
      final data = await api.get('/search', query: {
          'order-by': 'newest',
          'page': nextPage,
          'page-size': pageSize,
          if (section != null && section!.isNotEmpty) 'section': section,
        },
      );

      debugPrint(data.toString());

      final resp = data['response'] as Map<String, dynamic>;
      final int currentPage = (resp['currentPage'] as int?) ?? nextPage;
      final int pages = (resp['pages'] as int?) ?? currentPage;
      final results = (resp['results'] as List).cast<Map<String, dynamic>>();

      final newArticles = results.map(Article.fromGuardian).toList();
      items = <Article>[...items, ...newArticles];   // append to existing list
      page = currentPage;                            // record current page
      hasMore = currentPage < pages;                 // compute if more pages remain
      status = NewsStatus.success;                   // set success for UI
      errorMessage = null;                           // clear any previous error
      notifyListeners();
    } catch (e) {
      // Normalize errors to a friendly failure state
      status = NewsStatus.failure;
      errorMessage = 'Failed to load news';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    // Reset state to refresh from page 1
    status = NewsStatus.refreshing;
    items = <Article>[];
    hasMore = true;
    page = 0;
    notifyListeners();

    await fetchNextPage();
  }

  Future<void> changeSection(String? newSection) async {
    section = newSection;
    await refresh(); // Changing section reloads from page 1
  }
}

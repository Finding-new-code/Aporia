import 'dart:async';
import 'package:aporia/core/network/api_client.dart';

class DiscoverItem {
  final String title;
  final String description;
  final String imageUrl;
  final String category;

  DiscoverItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
  });
}

class DiscoverStore {
  bool isLoading = false;
  String selectedCategory = 'All';
  List<String> categories = [
    'All',
    'Tech',
    'Finance',
    'Art',
    'Science',
    'Health',
  ];
  List<DiscoverItem> items = [];
  String? error;
}

/// Standalone discover state manager. Uses its own static store so it doesn't
/// collide with the single DataFlow global store slot.
class DiscoverDataflow {
  DiscoverDataflow._();

  static final DiscoverStore _store = DiscoverStore();
  static DiscoverStore get store => _store;

  static final _controller = StreamController<DiscoverStore>.broadcast();
  static Stream<DiscoverStore> get stream => _controller.stream;

  static void _notify() => _controller.add(_store);

  static Future<void> loadItems({String? category}) async {
    _store.isLoading = true;
    if (category != null) {
      _store.selectedCategory = category;
    }
    _store.error = null;
    _notify();

    try {
      final String topic = _store.selectedCategory == 'All' 
          ? 'tech' 
          : _store.selectedCategory.toLowerCase();
          
      final response = await ApiClient().get(
        '/discover',
        queryParameters: {'topic': topic, 'mode': 'normal'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> blogs = response.data['blogs'] ?? [];
        
        // Remove duplicates based on title and limit to 15 items for performance
        final uniqueBlogs = <String, dynamic>{};
        for (var blog in blogs) {
          final title = blog['title']?.toString() ?? '';
          if (title.isNotEmpty && !uniqueBlogs.containsKey(title)) {
            uniqueBlogs[title] = blog;
          }
        }

        _store.items = uniqueBlogs.values.take(15).map((item) {
          final fallbackImage = 'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&q=80&w=800';
          
          return DiscoverItem(
            title: item['title']?.toString() ?? 'No Title',
            description: item['content']?.toString() ?? '',
            imageUrl: item['thumbnail']?.toString() ?? item['img_src']?.toString() ?? fallbackImage,
            category: _store.selectedCategory,
          );
        }).toList();
      } else {
        _store.error = 'Failed to load discovery items.';
      }
    } catch (e) {
      _store.error = 'Failed to load discovery items. Please check your connection.';
    } finally {
      _store.isLoading = false;
      _notify();
    }
  }
}

// Thin shim so DiscoverPage's action call still compiles
void initDiscoverDataflow() {
  // No-op: DiscoverDataflow now manages its own static state
}

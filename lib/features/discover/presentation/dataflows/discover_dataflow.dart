import 'dart:async';

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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final allItems = [
        DiscoverItem(
          title: 'The Future of AI Agents in Development',
          description:
              'Exploring how autonomous agents are changing the software engineering landscape and what it means for developers.',
          imageUrl:
              'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&q=80&w=800',
          category: 'Tech',
        ),
        DiscoverItem(
          title: 'Understanding Global Markets in 2026',
          description:
              'A comprehensive deep dive into the macroeconomic trends shaping the financial sector this year.',
          imageUrl:
              'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&q=80&w=800',
          category: 'Finance',
        ),
        DiscoverItem(
          title: 'Generative Art: A New Era of Creativity',
          description:
              'How artists are leveraging machine learning to create stunning, never-before-seen visual aesthetics.',
          imageUrl:
              'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?auto=format&fit=crop&q=80&w=800',
          category: 'Art',
        ),
        DiscoverItem(
          title: 'Breakthroughs in Quantum Computing',
          description:
              'Recent advancements have pushed quantum processors past the 1,000-qubit barrier.',
          imageUrl:
              'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&q=80&w=800',
          category: 'Science',
        ),
        DiscoverItem(
          title: 'The Rise of Personalized Medicine',
          description:
              'Tailoring healthcare treatments to individual genetic profiles is becoming a reality.',
          imageUrl:
              'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?auto=format&fit=crop&q=80&w=800',
          category: 'Health',
        ),
      ];

      if (_store.selectedCategory == 'All') {
        _store.items = allItems;
      } else {
        _store.items = allItems
            .where((item) => item.category == _store.selectedCategory)
            .toList();
      }
    } catch (e) {
      _store.error = 'Failed to load discovery items.';
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

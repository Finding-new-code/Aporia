import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/discover/presentation/dataflows/discover_dataflow.dart';
import 'package:aporia/features/discover/presentation/widgets/discover_card.dart';
import 'package:aporia/features/discover/presentation/widgets/discover_shimmer.dart';
import 'package:aporia/features/settings/presentation/widgets/app_drawer.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (DiscoverDataflow.store.items.isEmpty) {
      DiscoverDataflow.loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundBlack,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Discover',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DiscoverStore>(
        stream: DiscoverDataflow.stream,
        initialData: DiscoverDataflow.store,
        builder: (context, snapshot) {
          final store = snapshot.data ?? DiscoverDataflow.store;
          return Column(
            children: [
              // Category Chips
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: store.categories.length,
                  itemBuilder: (context, index) {
                    final category = store.categories[index];
                    final isSelected = store.selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected && !store.isLoading) {
                            DiscoverDataflow.loadItems(category: category);
                          }
                        },
                        backgroundColor: AppTheme.backgroundBlack,
                        selectedColor: Colors.white,
                        side: BorderSide(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content Area
              Expanded(
                child: store.isLoading
                    ? const DiscoverShimmerLoading()
                    : store.error != null
                    ? Center(
                        child: Text(
                          store.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: AppTheme.surfaceLightGray,
                        onRefresh: () => DiscoverDataflow.loadItems(
                          category: store.selectedCategory,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: store.items.length,
                          itemBuilder: (context, index) {
                            return DiscoverCard(item: store.items[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

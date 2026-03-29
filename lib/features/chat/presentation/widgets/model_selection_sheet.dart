import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/chat/presentation/dataflows/chat_dataflow.dart';

class ModelSelectionSheet extends StatefulWidget {
  const ModelSelectionSheet({super.key});

  @override
  State<ModelSelectionSheet> createState() => _ModelSelectionSheetState();
}

class _ModelSelectionSheetState extends State<ModelSelectionSheet> {
  @override
  void initState() {
    super.initState();
    // Load models initially (will also be triggered if provider changes)
    if (ChatDataflow.store.availableProviders.isEmpty) {
      LoadProvidersAction().execute();
      LoadModelsAction().execute(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDarkGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: StreamBuilder<ChatStore>(
        stream: ChatDataflow.stream,
        initialData: ChatDataflow.store,
        builder: (context, snapshot) {
          final store = snapshot.data ?? ChatDataflow.store;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   const Text(
                    'Select Model',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  )
                 ],
               ),
              const SizedBox(height: 16),
              
              if (store.availableProviders.isNotEmpty) ...[
                const Text(
                  'Providers',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: store.availableProviders.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final provider = store.availableProviders[index];
                      // For simplicity we aren't tracking selectedProvider in store, 
                      // but we could just re-fetch loadProviderModels on tap
                      return ActionChip(
                        label: Text(provider.name, style: const TextStyle(color: Colors.white)),
                        backgroundColor: AppTheme.surfaceLightGray.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onPressed: () {
                           LoadProviderModelsAction(provider.id).execute();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              const Text(
                'Available Models',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 8),

              if (store.availableModels.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: Colors.white54),
                  ),
                )
              else
                ...store.availableModels.map((model) {
                  final isSelected = store.selectedModel?.name == model.name;
                  return _buildModelItem(
                    title: model.name,
                    subtitle: model.type,
                    isSelected: isSelected,
                    onTap: () {
                      SelectModelAction(model).execute();
                      Navigator.pop(context);
                    },
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModelItem({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.green : Colors.white54,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

/// Dedicated mode for reordering categories — collapsed headers only, so
/// drags are unambiguous (item drags stay on the home screen).
class ReorderCategoriesScreen extends StatelessWidget {
  const ReorderCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reorder categories')),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(12),
        buildDefaultDragHandles: false,
        itemCount: app.categories.length,
        onReorderItem: app.reorderCategories,
        itemBuilder: (_, i) {
          final cat = app.categories[i];
          return Card(
            key: ValueKey('cat-${cat.id}'),
            child: ListTile(
              leading: Text(cat.emoji, style: const TextStyle(fontSize: 21)),
              title: Text(cat.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${cat.items.length} items'),
              trailing: ReorderableDragStartListener(
                index: i,
                child: const Icon(Icons.drag_indicator),
              ),
            ),
          );
        },
      ),
    );
  }
}

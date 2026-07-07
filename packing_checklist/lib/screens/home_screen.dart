import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/category_card.dart';
import '../widgets/sheets.dart';
import 'reorder_categories_screen.dart';

enum _MenuAction { saveTemplate, resetTemplate, uncheckAll, reorderCategories }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (!app.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing Checklist',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          PopupMenuButton<_MenuAction>(
            onSelected: (action) => _onMenu(context, action),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _MenuAction.saveTemplate,
                child: ListTile(
                    leading: Icon(Icons.bookmark_add_outlined),
                    title: Text('Save as template')),
              ),
              PopupMenuItem(
                value: _MenuAction.resetTemplate,
                child: ListTile(
                    leading: Icon(Icons.restart_alt),
                    title: Text('Reset from template')),
              ),
              PopupMenuItem(
                value: _MenuAction.uncheckAll,
                child: ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text('Uncheck all')),
              ),
              PopupMenuItem(
                value: _MenuAction.reorderCategories,
                child: ListTile(
                    leading: Icon(Icons.swap_vert),
                    title: Text('Reorder categories')),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _ProgressHeader(app: app),
        ),
      ),
      body: app.categories.isEmpty
          ? const Center(
              child: Text('No categories yet — tap + to add one',
                  style: TextStyle(color: AppColors.mutedText)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: app.categories.length,
              itemBuilder: (_, i) =>
                  CategoryCard(category: app.categories[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategorySheet(context),
        tooltip: 'Add category',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onMenu(BuildContext context, _MenuAction action) async {
    final app = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);

    switch (action) {
      case _MenuAction.saveTemplate:
        final ok = await _confirm(
          context,
          title: 'Save as template?',
          body: 'Saves the current categories, items, quantities and tags as '
              'your template (packed checkmarks are not saved). This replaces '
              'the previous template.',
          confirmLabel: 'Save',
        );
        if (ok) {
          await app.saveTemplate();
          messenger.showSnackBar(
              const SnackBar(content: Text('Template saved')));
        }
      case _MenuAction.resetTemplate:
        final ok = await _confirm(
          context,
          title: 'Reset from template?',
          body: 'Replaces the current checklist with your saved template and '
              'clears all checkmarks. Changes made since the template was '
              'saved will be lost.',
          confirmLabel: 'Reset',
          destructive: true,
        );
        if (ok) {
          await app.resetFromTemplate();
          messenger.showSnackBar(
              const SnackBar(content: Text('Checklist reset from template')));
        }
      case _MenuAction.uncheckAll:
        await app.uncheckAll();
      case _MenuAction.reorderCategories:
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ReorderCategoriesScreen()),
          );
        }
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: Colors.red)
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }
}

/// "X of Y packed" + live progress bar, pinned under the app bar title.
class _ProgressHeader extends StatelessWidget {
  final AppState app;
  const _ProgressHeader({required this.app});

  @override
  Widget build(BuildContext context) {
    final allPacked = app.totalItems > 0 && app.packedItems == app.totalItems;
    final pct =
        app.totalItems == 0 ? 0 : (app.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                allPacked
                    ? 'All packed! Time to go 🎉'
                    : '${app.packedItems} of ${app.totalItems} items packed',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                allPacked ? '🎉' : '$pct%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: app.progress,
              minHeight: 6,
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

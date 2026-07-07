import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/item.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Add a new item ([item] == null) or edit an existing one, via a
/// lightweight bottom sheet: name, quantity stepper, optional tag.
Future<void> showItemSheet(BuildContext context, Category category,
    {Item? item}) {
  final app = context.read<AppState>();
  final nameCtl = TextEditingController(text: item?.name ?? '');
  final tagCtl = TextEditingController(text: item?.tag ?? '');
  var quantity = item?.quantity ?? 1;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        void submit() {
          final name = nameCtl.text.trim();
          if (name.isEmpty) return;
          final tag = tagCtl.text.trim().isEmpty ? null : tagCtl.text.trim();
          if (item == null) {
            app.addItem(category, name, quantity, tag);
          } else {
            app.editItem(item, name, quantity, tag);
          }
          Navigator.pop(ctx);
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item == null
                    ? 'Add item — ${category.emoji} ${category.name}'
                    : 'Edit item',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Item name',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => submit(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tagCtl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Tag (optional)',
                        hintText: 'e.g. Carry-on, Beach',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => submit(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Qty', style: Theme.of(ctx).textTheme.labelLarge),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: quantity > 1
                        ? () => setSheetState(() => quantity--)
                        : null,
                  ),
                  Text('$quantity',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setSheetState(() => quantity++),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: submit,
                child: Text(item == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// Add a new category ([category] == null) or rename/re-emoji an existing one.
Future<void> showCategorySheet(BuildContext context, {Category? category}) {
  final app = context.read<AppState>();
  final nameCtl = TextEditingController(text: category?.name ?? '');
  final emojiCtl = TextEditingController(text: category?.emoji ?? '');

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      void submit() {
        final name = nameCtl.text.trim();
        if (name.isEmpty) return;
        final emoji = emojiCtl.text.trim().isEmpty ? '📦' : emojiCtl.text.trim();
        if (category == null) {
          app.addCategory(name, emoji);
        } else {
          app.editCategory(category, name, emoji);
        }
        Navigator.pop(ctx);
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(category == null ? 'Add category' : 'Edit category',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                SizedBox(
                  width: 76,
                  child: TextField(
                    controller: emojiCtl,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Emoji',
                      hintText: '📦',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: nameCtl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Category name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => submit(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: submit,
              child: Text(category == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      );
    },
  );
}

/// Direct-edit dialog for an item's quantity.
Future<void> showQuantityDialog(BuildContext context, Item item) {
  final app = context.read<AppState>();
  final ctl = TextEditingController(text: '${item.quantity}');

  return showDialog(
    context: context,
    builder: (ctx) {
      void submit() {
        final value = int.tryParse(ctl.text.trim());
        if (value != null && value >= 1) {
          app.setQuantity(item, value);
        }
        Navigator.pop(ctx);
      }

      return AlertDialog(
        title: Text('Quantity — ${item.name}'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: submit, child: const Text('Save')),
        ],
      );
    },
  );
}

/// Direct-edit dialog for the trip name shown under the app bar title.
Future<void> showTripNameDialog(BuildContext context, String currentName) {
  final app = context.read<AppState>();
  final ctl = TextEditingController(text: currentName);

  return showDialog(
    context: context,
    builder: (ctx) {
      void submit() {
        app.setTripName(ctl.text.trim());
        Navigator.pop(ctx);
      }

      return AlertDialog(
        title: const Text('Trip name'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Japan trip',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: submit, child: const Text('Save')),
        ],
      );
    },
  );
}

/// Long-press actions for a category header: edit or delete.
Future<void> showCategoryActions(BuildContext context, Category category) {
  final app = context.read<AppState>();

  return showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit category'),
            onTap: () {
              Navigator.pop(ctx);
              showCategorySheet(context, category: category);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete category',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(ctx);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dctx) => AlertDialog(
                  title: Text('Delete "${category.name}"?'),
                  content: Text(category.items.isEmpty
                      ? 'This category is empty.'
                      : 'This deletes the category and its '
                          '${category.items.length} item'
                          '${category.items.length == 1 ? '' : 's'}.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(dctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                app.deleteCategory(category);
              }
            },
          ),
        ],
      ),
    ),
  );
}

/// Small colored pill showing an item's tag.
class TagBadge extends StatelessWidget {
  final String tag;
  const TagBadge(this.tag, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.tagColor(tag),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        tag,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

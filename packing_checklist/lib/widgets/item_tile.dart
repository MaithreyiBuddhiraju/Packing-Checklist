import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/item.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'sheets.dart';

/// One checklist row: checkbox · name (+ tag pill) · qty stepper · drag handle.
/// Tap toggles packed, long-press edits, swipe left deletes (with undo).
class ItemTile extends StatelessWidget {
  final Item item;
  final Category category;
  final int index;

  const ItemTile({
    super.key,
    required this.item,
    required this.category,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();

    return Dismissible(
      key: ValueKey('dismiss-item-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        final messenger = ScaffoldMessenger.of(context);
        app.deleteItem(item);
        messenger.showSnackBar(SnackBar(
          content: Text('Deleted "${item.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => app.restoreItem(item),
          ),
        ));
      },
      child: InkWell(
        onTap: () => app.togglePacked(item),
        onLongPress: () => showItemSheet(context, category, item: item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: item.packed ? const Color(0xFFF7FBF8) : null,
            border: const Border(
                bottom: BorderSide(color: Color(0xFFFAF3EC))),
          ),
          child: Row(
            children: [
              Checkbox(
                value: item.packed,
                onChanged: (_) => app.togglePacked(item),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.packed ? AppColors.struckText : null,
                        decoration:
                            item.packed ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.struckText,
                      ),
                    ),
                    if (item.tag != null) ...[
                      const SizedBox(height: 3),
                      // Tap the pill to edit/remove the tag without hunting
                      // for the long-press edit sheet.
                      GestureDetector(
                        onTap: () =>
                            showItemSheet(context, category, item: item),
                        child: TagBadge(item.tag!),
                      ),
                    ],
                  ],
                ),
              ),
              _QtyStepper(item: item),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Icon(Icons.drag_indicator,
                      size: 20, color: AppColors.struckText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final Item item;
  const _QtyStepper({required this.item});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepButton(
          icon: Icons.remove,
          enabled: item.quantity > 1,
          onTap: () => app.setQuantity(item, item.quantity - 1),
        ),
        InkWell(
          onTap: () => showQuantityDialog(context, item),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minWidth: 28),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        _stepButton(
          icon: Icons.add,
          enabled: true,
          onTap: () => app.setQuantity(item, item.quantity + 1),
        ),
      ],
    );
  }

  Widget _stepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.navy : AppColors.struckText,
        ),
      ),
    );
  }
}

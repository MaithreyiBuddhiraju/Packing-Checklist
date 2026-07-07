import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'item_tile.dart';
import 'sheets.dart';

/// Collapsible category card: tappable header with packed-count badge,
/// reorderable item list, and an inline "Add item" row.
class CategoryCard extends StatelessWidget {
  final Category category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final done = category.allPacked;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => app.toggleCollapsed(category),
            onLongPress: () => showCategoryActions(context, category),
            child: Container(
              color: done ? const Color(0xFFF0FAF4) : null,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              child: Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 21)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      done ? '${category.name} ✓' : category.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.badgeDoneBg
                          : AppColors.badgeTodoBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${category.packedCount}/${category.items.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: done
                            ? AppColors.badgeDoneFg
                            : AppColors.badgeTodoFg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: category.collapsed ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more,
                        size: 18, color: AppColors.struckText),
                  ),
                ],
              ),
            ),
          ),
          if (!category.collapsed) ...[
            const Divider(height: 1, color: Color(0xFFF0E8DE)),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: category.items.length,
              onReorderItem: (oldIndex, newIndex) =>
                  app.reorderItems(category, oldIndex, newIndex),
              itemBuilder: (_, i) => ItemTile(
                key: ValueKey('item-${category.items[i].id}'),
                item: category.items[i],
                category: category,
                index: i,
              ),
            ),
            InkWell(
              onTap: () => showItemSheet(context, category),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 16, color: AppColors.navy),
                    SizedBox(width: 5),
                    Text(
                      'Add item',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

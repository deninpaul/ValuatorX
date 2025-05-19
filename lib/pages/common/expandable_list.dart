import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

class ExpandableList<T> extends StatefulWidget {
  final List<T> items;
  final int initialCount;
  final int incrementCount;
  final int skeletonCount;
  final ItemBuilder<T> itemBuilder;
  final bool isLoading;

  const ExpandableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.isLoading,
    this.initialCount = 10,
    this.incrementCount = 10,
    this.skeletonCount = 5,
  });

  @override
  State<ExpandableList<T>> createState() => _ExpandableListState<T>();
}

class _ExpandableListState<T> extends State<ExpandableList<T>> {
  late int _displayCount;

  @override
  void initState() {
    super.initState();
    _displayCount = widget.initialCount;
  }

  void _loadMore() {
    setState(() => _displayCount += widget.incrementCount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final divider = Divider(color: theme.dividerColor.withAlpha(64), indent: 24, endIndent: 24);
    final minHeight = MediaQuery.of(context).size.height - 240;

    final int itemsToShow =
        widget.items.isEmpty
            ? 0
            : _displayCount > widget.items.length
            ? widget.items.length
            : _displayCount;
    final bool showViewMoreButton = itemsToShow < widget.items.length;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isLoading)
            ListView.separated(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 12),
              itemCount: widget.skeletonCount,
              separatorBuilder: (ctx, index) => divider,
              itemBuilder: (context, index) => SkeletonListTile(),
            )
          else
            ListView.separated(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 12),
              itemCount: itemsToShow,
              separatorBuilder: (ctx, index) => divider,
              itemBuilder: (context, index) {
                return widget.itemBuilder(context, widget.items[index], index);
              },
            ),
          if (showViewMoreButton && !widget.isLoading)
            Padding(padding: const EdgeInsets.only(bottom: 0), child: TextButton(onPressed: _loadMore, child: Text('View More')))
          else
            SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHigh,
      highlightColor: colorScheme.surfaceContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: Container(
            height: 12,
            margin: EdgeInsets.only(right: 80),
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(16)),
          ),
          subtitle: Container(
            height: 12,
            margin: EdgeInsets.only(right: 160, top: 8),
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(16)),
          ),
          trailing: Container(
            width: 70,
            height: 32,
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(40)),
          ),
        ),
      ),
    );
  }
}

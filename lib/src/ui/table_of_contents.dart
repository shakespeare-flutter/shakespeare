
import 'package:flutter/material.dart';
import '../../epub_view_enhanced.dart';
import '../data/models/chapter.dart';

class EpubViewTableOfContents extends StatelessWidget {
  const EpubViewTableOfContents({
    required this.controller,
    this.padding,
    this.itemBuilder,
    this.loader,
    this.onItemTapped,
    Key? key,
  }) : super(key: key);

  final EdgeInsetsGeometry? padding;
  final EpubController controller;
  final Function? onItemTapped;

  final Widget Function(
    BuildContext context,
    int index,
    EpubViewChapter chapter,
    int itemCount,
  )? itemBuilder;
  final Widget? loader;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<EpubViewChapter>>(
        valueListenable: controller.tableOfContentsListenable,
        builder: (_, data, child) {
          Widget content;

          if (data.isNotEmpty) {
            content = ListView.builder(
              padding: padding,
              key: Key('$runtimeType.content'),
              itemBuilder: (context, index) =>
                  itemBuilder?.call(context, index, data[index], data.length) ??
                  ListTile(
                    title: Text(data[index].title!.trim()),
                    onTap: () {
                      controller.scrollTo(index: data[index].startIndex);
                      if (onItemTapped != null) onItemTapped!();
                    },
                  ),
              itemCount: data.length,
            );
          } else {
            content = KeyedSubtree(
              key: Key('$runtimeType.loader'),
              child: loader ?? const Center(child: CircularProgressIndicator()),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                FadeTransition(opacity: animation, child: child),
            child: content,
          );
        },
      );
}

// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_grid_layout/flutter_grid_layout.dart';
import 'package:flutter_grid_layout/src/list_ext.dart';

class GridContainer extends StatelessWidget {
  /// Columns size declaration
  // 0.5 -> 50%, 10 -> 10 DIP, null -> auto
  final List<double?> columns;

  /// Rows size declaration
  // 0.5 -> 50%, 10 -> 10 DIP, null -> auto
  final List<double?> rows;

  /// List of elements for plotting
  final List<GridItem> children;

  /// Type of alignment
  // Right-to-Left: MainAxisAlignment.end
  // Left-to-Right: MainAxisAlignment.start
  final MainAxisAlignment alignment;

  const GridContainer({
    super.key,
    required this.children,
    required this.columns,
    required this.rows,
    this.alignment = MainAxisAlignment.start,
  });

  // Calculate DIP for relative values
  List<double> _calc(double size, List<double?> scope) {
    if (alignment == MainAxisAlignment.end) {
      scope = scope.reversed.toList();
    }
    int restCount = scope.where((e) => e == null).length;
    double takenSize = 0;
    for (int i = 0; i < scope.length; i++) {
      if (scope[i] == null) {
        continue;
      }
      double value = scope[i]!;
      if (value > 0 && value < 1) {
        scope[i] = value * size;
        takenSize += scope[i]!;
      } else {
        takenSize += value;
      }
    }
    if (takenSize > size) {
      double cut = (size - takenSize) / (scope.length - restCount);
      scope = scope.map((value) => value != null ? value + cut : null).toList();
      takenSize = size;
    }
    if (restCount > 0) {
      double rest = (size - takenSize) / restCount;
      scope = scope.map((value) => value ?? rest).toList();
    }
    scope.insert(0, 0.0);
    return scope.cast();
  }

  // Restate widths from zero-point
  List<double> _scale(List<double> scope) {
    return scope
        .asMap()
        .entries
        .map((entry) =>
            scope.sublist(0, entry.key + 1).fold(0.0, (v, e) => v + e))
        .toList();
  }

  // Calculate widths from relative values
  List<double> _calcWidth(double maxWidth) => _calc(maxWidth, rows);

  // Calculate heights from relative values
  List<double> _calcHeight(double maxHeight) => _calc(maxHeight, columns);

  GridItem _get(index) {
    GridItem item = children[index];
    if (alignment == MainAxisAlignment.end) {
      item = GridItem(
        order: item.zIndex,
        start: Size(columns.length - item.end.width, item.start.height),
        end: Size(columns.length - item.start.width, item.end.height),
        child: item.child,
      );
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    if (columns.isEmpty || rows.isEmpty || children.isEmpty) {
      return const SizedBox();
    }
    children.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return LayoutBuilder(builder: (context, constraints) {
      final width = _scale(_calcWidth(constraints.maxWidth));
      final height = _scale(_calcHeight(constraints.maxHeight));
      return Stack(
        children: List<Widget>.generate(children.length, (index) {
          final item = _get(index);
          final itemWidth =
              width.by(item.end.width) - width.by(item.start.width);
          final itemHeight =
              height.by(item.end.height) - height.by(item.start.height);
          if (itemWidth <= 0 || itemHeight <= 0) {
            return const SizedBox();
          }
          return Container(
            margin: EdgeInsets.only(
              left: width.by(item.start.width),
              top: height.by(item.start.height),
            ),
            constraints: BoxConstraints(
              maxWidth: itemWidth,
              minWidth: itemWidth,
              maxHeight: itemHeight,
              minHeight: itemHeight,
            ),
            width: itemWidth,
            height: itemHeight,
            child: item.child,
          );
        }),
      );
    });
  }
}

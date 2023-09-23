// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_grid_layout/flutter_grid_layout.dart';
import 'package:flutter_grid_layout/src/list_ext.dart';

class GridContainer extends StatelessWidget {
  // 0.5 -> 50%, 10 -> 10 DIP, null -> auto
  final List<double?> columns;
  // 0.5 -> 50%, 10 -> 10 DIP, null -> auto
  final List<double?> rows;
  final List<GridItem> children;

  const GridContainer({
    super.key,
    required this.children,
    required this.columns,
    required this.rows,
  });

  List<double> _calc(double size, List<double?> scope) {
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

  List<double> _scale(List<double> scope) {
    return scope
        .asMap()
        .entries
        .map((entry) =>
            scope.sublist(0, entry.key + 1).fold(0.0, (v, e) => v + e))
        .toList();
  }

  List<double> _calcWidth(double maxWidth) {
    return _calc(maxWidth, rows);
  }

  List<double> _calcHeight(double maxHeight) {
    return _calc(maxHeight, columns);
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
          final item = children[index];
          final itemWidth =
              width.by(item.end.width) - width.by(item.start.width);
          final itemHeight =
              height.by(item.end.height) - height.by(item.start.height);
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

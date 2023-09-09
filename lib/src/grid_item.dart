// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/widgets.dart';

class GridItem extends StatelessWidget {
  // Indexes from GridContainer(columns, rows)
  final Size start;
  // Indexes from GridContainer(columns, rows)
  final Size end;
  // Layer index
  final int zIndex;
  final Widget child;

  const GridItem({
    super.key,
    required this.child,
    required this.start,
    required this.end,
    int? order,
  }) : zIndex = order ?? 0;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

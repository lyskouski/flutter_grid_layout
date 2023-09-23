// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_grid_layout/flutter_grid_layout.dart';
import 'basic_page.dart';

class ComponentsBuilder extends StatelessWidget {
  final List<ComponentData> data;
  final bool editMode;
  final Function? adjust;
  final Function? delete;
  final _shift = InterfaceComponent.shift;
  final _order = InterfaceComponent.order;
  final _start = InterfaceComponent.start;
  final _end = InterfaceComponent.end;

  const ComponentsBuilder(
    this.data, {
    super.key,
    this.editMode = false,
    this.adjust,
    this.delete,
  });

  void resize(ComponentData change, Size start) {
    final scope = data[change[_order]];
    scope[_order] = change[_order];
    if (change[_shift] != null) {
      scope[InterfaceComponent.endX] +=
          start.width - scope[InterfaceComponent.startX];
      scope[InterfaceComponent.endY] +=
          start.height - scope[InterfaceComponent.startY];
      scope[InterfaceComponent.startX] = start.width;
      scope[InterfaceComponent.startY] = start.height;
    } else if (change[_start] != null) {
      scope[InterfaceComponent.startX] = start.width;
      scope[InterfaceComponent.startY] = start.height;
    } else if (change[_end] != null) {
      scope[InterfaceComponent.endX] = start.width + 1.0;
      scope[InterfaceComponent.endY] = start.height + 1.0;
    }
    adjust!(scope[_order], scope);
  }

  @override
  Widget build(BuildContext context) {
    const rowsCount = 6;
    const columnsCount = 6;
    return GridContainer(
      rows: List.filled(rowsCount, null),
      columns: List.filled(columnsCount, null),
      children: editMode
          ? [
              ...List.generate(rowsCount * columnsCount, (i) {
                final start = Size(
                  i % rowsCount.toDouble(),
                  (i ~/ rowsCount).toDouble(),
                );
                return GridItem(
                  start: start,
                  end: Size(start.width + 1, start.height + 1),
                  order: 0,
                  child: DragTarget<ComponentData>(
                    onWillAccept: (_) => true,
                    onAccept: (change) => resize(change, start),
                    builder: (context, candidateData, _) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: candidateData.isEmpty
                            ? null
                            : Colors.green.shade200,
                      ),
                    ),
                  ),
                );
              }),
              ...List.generate(
                data.length,
                (i) => GridItem(
                  start: Size(data[i][InterfaceComponent.startX] + .0,
                      data[i][InterfaceComponent.startY] + .0),
                  end: Size(data[i][InterfaceComponent.endX] + .0,
                      data[i][InterfaceComponent.endY] + .0),
                  order: i + 1,
                  child: Draggable<ComponentData>(
                    data: {...data[i], _order: i, _shift: true},
                    feedback: Container(
                      color: Colors.amberAccent,
                      width: 32,
                      height: 24,
                    ),
                    child: Container(color: data[i][InterfaceComponent.color]),
                  ),
                ),
              ),
            ]
          : List.generate(
              data.length,
              (i) => GridItem(
                    start: Size(data[i][InterfaceComponent.startX] + .0,
                        data[i][InterfaceComponent.startY] + .0),
                    end: Size(data[i][InterfaceComponent.endX] + .0,
                        data[i][InterfaceComponent.endY] + .0),
                    child: const SizedBox(),
                  )),
    );
  }
}

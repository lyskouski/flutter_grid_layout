// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_grid_layout/src/grid_container.dart';
import 'package:flutter_grid_layout/src/grid_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForegroundChartPainter', () {
    final testCases = [
      (
        title: 'Plot an empty scope',
        columns: [],
        rows: [],
        children: [],
      ),
      (
        title: 'Plot centered item',
        columns: [0.2, null, 0.2],
        rows: [0.2, null, 0.2],
        children: [
          GridItem(
            start: const Size(1, 1),
            end: const Size(2, 2),
            child: Container(color: Colors.red),
          )
        ],
      ),
      (
        title: 'Plot multiple nested items',
        columns: [0.2, 0.3, 0.3, 0.2],
        rows: [0.2, 0.3, 0.3, 0.2],
        children: [
          GridItem(
            start: const Size(0, 0),
            end: const Size(4, 1),
            child: Container(color: Colors.red),
          ),
          GridItem(
            start: const Size(1, 0),
            end: const Size(3, 4),
            order: 1,
            child: Container(color: Colors.blue.withOpacity(0.5)),
          ),
          GridItem(
            start: const Size(2, 3),
            end: const Size(4, 4),
            child: Container(color: Colors.green),
          ),
        ],
      ),
    ];

    for (int i = 0; i < testCases.length; i++) {
      testWidgets(testCases[i].title, (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            home: RepaintBoundary(
              child: Container(
                decoration: const BoxDecoration(color: Colors.yellow),
                child: GridContainer(
                  columns: testCases[i].columns.cast(),
                  rows: testCases[i].rows.cast(),
                  children: testCases[i].children.cast(),
                ),
              ),
            ),
          ),
        );
        // flutter test --update-goldens
        await expectLater(
          find.byType(RepaintBoundary).first,
          matchesGoldenFile('./grid_container_test.dart.$i.png'),
        );
      });
    }
  });
}

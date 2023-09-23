// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'components_builder.dart';

typedef ComponentData = Map<String, dynamic>;

abstract class InterfaceComponent {
  static const key = '_component';
  static const order = '_order';
  static const endX = '_end_x';
  static const endY = '_end_y';
  static const startX = '_start_x';
  static const startY = '_start_y';
  static const start = '_start';
  static const end = '_end';
  static const shift = '_shift';
  static const color = 'color';
}

class BasicPage extends StatefulWidget {
  const BasicPage({super.key});

  @override
  BasicPageState createState() => BasicPageState();
}

class BasicPageState extends State<BasicPage> {
  List<ComponentData> data = [];
  late String key;

  Future<void> _save() async {
    // ... store data
    setState(() {});
  }

  Future<void> save() async {
    await _save();
  }

  Future<void> drop() async {
    data.clear();
    // ... update store
  }

  Future<void> add(String key) async {
    List<Color> colors = Colors.primaries;
    Random random = Random();
    data.add({
      InterfaceComponent.key: key,
      InterfaceComponent.startX: 0,
      InterfaceComponent.startY: 0,
      InterfaceComponent.endX: 1,
      InterfaceComponent.endY: 1,
      InterfaceComponent.color: colors[random.nextInt(colors.length)],
    });
    await _save();
  }

  Future<void> adjust(int index, ComponentData change) async {
    data[index] = change;
    await _save();
  }

  Future<void> delete(int index) async {
    data.removeAt(index);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: Colors.blueGrey,
        title: const Text('Layout Manager'),
        centerTitle: true,
        leadingWidth: 120,
        leading: Row(
          children: [
            IconButton(
              hoverColor: Colors.transparent,
              icon: const Icon(
                Icons.save,
                color: Colors.white70,
              ),
              tooltip: 'Save',
              onPressed: save,
            ),
            IconButton(
              hoverColor: Colors.transparent,
              icon: const Icon(
                Icons.cancel,
                color: Colors.white70,
              ),
              tooltip: 'Delete',
              onPressed: drop,
            ),
          ],
        ),
        actions: [
          IconButton(
            hoverColor: Colors.transparent,
            icon: const Icon(
              Icons.add_circle_rounded,
              color: Colors.white70,
            ),
            tooltip: 'Add',
            onPressed: () => add(UniqueKey().toString()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ComponentsBuilder(data,
            editMode: true, adjust: adjust, delete: delete),
      ),
    );
  }
}

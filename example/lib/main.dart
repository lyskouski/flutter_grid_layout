import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_grid_layout/flutter_grid_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Serialized component state
typedef ComponentData = Map<String, dynamic>;

// Properties for ComponentData
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const BasicPage(),
    );
  }
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
    // ... other actions with `data`
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
      InterfaceComponent.endX: 1 + random.nextInt(3),
      InterfaceComponent.endY: 1 + random.nextInt(2),
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
                    child: const SizedBox(), // STUB
                  )),
    );
  }
}

// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file.

extension ListExt on List {
  // Safely get by index
  dynamic by(dynamic index) => this[(switch (index.runtimeType) {
        double => (index as double).toInt(),
        String => int.tryParse(index) ?? 0,
        _ => index
      })
          .clamp(0, length - 1)];
}

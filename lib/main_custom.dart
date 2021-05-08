import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double dragAmount = 0;
  double containerHeight = 50;
  int? startIndex;
  int? offset;

  List<Widget> getListTiles() {
    List<Widget> results = [];
    for (int i = 0; i < 10; i++) {
      results.add(
        Transform.translate(
          offset: startIndex != null &&
                  offset != null &&
                  (i >= startIndex! && i <= startIndex! + offset! ||
                      i >= startIndex! + offset! && i <= startIndex!)
              ? new Offset(dragAmount, 0)
              : new Offset(0, 0),
          child: GestureDetector(
            onHorizontalDragStart: (DragStartDetails deets) {
              startIndex = i;
              offset = 0;
            },
            onHorizontalDragUpdate: (DragUpdateDetails deets) {
              if (deets.primaryDelta != null) {
                setState(() {
                  dragAmount += deets.primaryDelta!;
                });
              }
              offset = (deets.localPosition.dy / containerHeight).floor();
            },
            onHorizontalDragEnd: (DragEndDetails deets) {
              setState(() {
                dragAmount = 0;
                startIndex = null;
                offset = null;
              });
            },
            child: Container(
              height: containerHeight,
              color: Colors.amber[600],
              child: Center(child: Text('Entry $i')),
            ),
          ),
        ),
      );
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Material App Bar'),
          ),
          body: ListView(children: getListTiles())),
    );
  }
}

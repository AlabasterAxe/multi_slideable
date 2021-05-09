import 'dart:math';

import 'package:flutter/material.dart';

const double LIST_ITEM_HEIGHT = 50;

Widget getTileItem(int i) {
  return Container(
    height: LIST_ITEM_HEIGHT - 1,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Buy ${i} more spam!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          Text("Now with 100% more salt!"),
        ],
      ),
    ),
  );
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: ListHomeView(),
      ),
    );
  }
}

class ListHomeView extends StatefulWidget {
  ListHomeView({Key? key}) : super(key: key);

  @override
  _ListHomeViewState createState() => _ListHomeViewState();
}

class _ListHomeViewState extends State<ListHomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController dragController;
  List<int> emails = List.generate(20, (i) => i);
  int? draggedIdx;
  int? dragOffset;

  @override
  void initState() {
    super.initState();
    dragController = AnimationController.unbounded(vsync: this);
  }

  List<Widget> _getListItems() {
    List<Widget> items = [];
    for (int i = 0; i < emails.length; i++) {
      bool shouldDrag = false;
      if (draggedIdx != null && dragOffset != null) {
        int topIdx = min(draggedIdx!, draggedIdx! + dragOffset!);
        int bottomIdx = max(draggedIdx!, draggedIdx! + dragOffset!);
        shouldDrag = (i >= topIdx && i <= bottomIdx);
      }
      items.add(AnimatedBuilder(
          animation: dragController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(shouldDrag ? dragController.value : 0, 0),
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (DragStartDetails deets) {
                    draggedIdx = i;
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails deets) {
                    if (deets.primaryDelta != null) {
                      dragController.value += deets.primaryDelta!;
                    }
                    setState(() {
                      dragOffset =
                          (deets.localPosition.dy / LIST_ITEM_HEIGHT).floor();
                    });
                  },
                  onHorizontalDragEnd: (DragEndDetails deets) {
                    dragController.value = 0;
                    draggedIdx = null;
                    dragOffset = null;
                  },
                  child: getTileItem(emails[i])),
            );
          }));
      items.add(AnimatedBuilder(
          animation: dragController,
          builder: (context, child) {
            return Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[800],
                indent: shouldDrag && dragController.value > 0
                    ? dragController.value
                    : 0,
                endIndent: shouldDrag && dragController.value < 0
                    ? dragController.value.abs()
                    : 0);
          }));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _getListItems(),
    );
  }
}

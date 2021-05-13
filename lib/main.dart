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
  late ScrollController scrollController = ScrollController();
  List<int> emails = List.generate(20, (i) => i);
  double actionThresholdRatio = .2;
  int? draggedIdx;
  int? dragOffset;

  @override
  void initState() {
    super.initState();
    dragController = AnimationController.unbounded(vsync: this);
  }

  void _clearDragIndices(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      draggedIdx = null;
      dragOffset = null;
    }
    dragController.removeStatusListener(_clearDragIndices);
  }

  void _removeItems(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (draggedIdx == null || dragOffset == null) {
        draggedIdx = null;
        dragOffset = null;
        return;
      }
      int topIdx = min(draggedIdx!, draggedIdx! + dragOffset!);
      int bottomIdx = max(draggedIdx!, draggedIdx! + dragOffset!);
      emails.removeRange(topIdx, bottomIdx + 1);

      draggedIdx = null;
      dragOffset = null;
      setState(() {});
      dragController.removeStatusListener(_removeItems);
      dragController.value = 0;
    }
  }

  void _animateDragEnd() {
    double screenWidth = MediaQuery.of(context).size.width;

    if (dragController.value.abs() < screenWidth * actionThresholdRatio) {
      dragController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      dragController.addStatusListener(_clearDragIndices);
    } else {
      if (dragController.value > 0) {
        dragController.animateTo(
          screenWidth,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        dragController.animateTo(
          -screenWidth,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      dragController.addStatusListener(_removeItems);
    }
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
                    _animateDragEnd();
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

  Widget _getSwipeActionIndicator() {
    if (!scrollController.hasClients ||
        draggedIdx == null ||
        dragOffset == null) {
      return Container();
    }

    double topPixelOffset =
        (min(draggedIdx!, draggedIdx! + dragOffset!) * LIST_ITEM_HEIGHT) -
            scrollController.offset;
    double bottomPixelOffset =
        ((max(draggedIdx!, draggedIdx! + dragOffset!) + 1) * LIST_ITEM_HEIGHT) -
            scrollController.offset;
    if (dragController.value > 0) {
      return AnimatedBuilder(
          animation: dragController,
          builder: (context, child) {
            return Positioned(
                left: 0,
                width: dragController.value,
                top: topPixelOffset,
                height: bottomPixelOffset - topPixelOffset,
                child: Container(
                    child: Icon(Icons.archive, color: Colors.white),
                    color: Colors.green));
          });
    }
    return AnimatedBuilder(
        animation: dragController,
        builder: (context, snapshot) {
          return Positioned(
              right: 0,
              width: dragController.value.abs(),
              top: topPixelOffset,
              height: bottomPixelOffset - topPixelOffset,
              child: Container(
                  child: Icon(Icons.delete, color: Colors.white),
                  color: Colors.red));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _getSwipeActionIndicator(),
        ListView(
          controller: scrollController,
          children: _getListItems(),
        ),
      ],
    );
  }
}

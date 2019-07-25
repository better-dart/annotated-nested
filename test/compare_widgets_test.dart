import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_api/test_api.dart' as matcher;
import 'package:nested/nested.dart';

void realWorldTest(String description, List<Widget> before, List<Widget> after,
    {bool skip}) {
  testWidgets(description, (tester) async {
    final realDetails = await realWorldPump(tester, before, after);
    final testedDetails = didChangeChildren(before, after);

    expect(
      testedDetails,
      const matcher.TypeMatcher<Details>()
          .having((b) => b.forgotten, 'forgotten',
              orderedEquals(realDetails.forgotten))
          .having((b) => b.inserted, 'inserted',
              orderedEquals(realDetails.inserted))
          .having(
              (b) => b.updated, 'updated', orderedEquals(realDetails.updated)),
    );
  }, skip: skip);
}

void main() {
  final key = GlobalKey();
  final key2 = GlobalKey();
  final key3 = GlobalKey();
  // realWorldTest('empty to something', [], [TestWidget()]);
  // realWorldTest('empty to something', [TestWidget()], [TestWidget()]);
  realWorldTest('empty to something', [
    TestWidget(key: key),
    TestWidget(key: key2),
  ], [
    TestWidget(key: key2),
    TestWidget(key: key),
  ]);
}

void Function(T) notificationToLocation<T extends _Details>(
    List<WidgetLocation> list) {
  return (notification) =>
      list.add(WidgetLocation(notification.index, notification.widget));
}

class TestWidget extends StatefulWidget {
  TestWidget({Key key}) : super(key: key);

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

Type _typeOf<T>() => T;

class _TestWidgetState extends State<TestWidget> {
  NotificationListener<_Details> owner;

  @override
  void initState() {
    super.initState();
    owner = context.ancestorWidgetOfExactType(
            _typeOf<NotificationListener<_Details>>())
        as NotificationListener<_Details>;

    owner.onNotification(InitState());
  }

  @override
  void didUpdateWidget(TestWidget oldWidget) {
    owner = context.ancestorWidgetOfExactType(
            _typeOf<NotificationListener<_Details>>())
        as NotificationListener<_Details>;
    owner.onNotification(DidUpdate());
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    owner.onNotification(Dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

Future<Details> realWorldPump(
  WidgetTester tester,
  List<Widget> before,
  List<Widget> after,
) async {
  final forgotten = <WidgetLocation>[];
  final updated = <WidgetLocation>[];
  final created = <WidgetLocation>[];

  await tester.pumpWidget(RealWorld(
    onInit: notificationToLocation(created),
    onDispose: notificationToLocation(forgotten),
    onUpdate: notificationToLocation(updated),
    children: before,
  ));

  forgotten.clear();
  updated.clear();
  created.clear();

  await tester.pumpWidget(RealWorld(
    onInit: notificationToLocation(created),
    onDispose: notificationToLocation(forgotten),
    onUpdate: notificationToLocation(updated),
    children: after,
  ));

  return Details(
    // make sure that the list is not mutated later
    inserted: UnmodifiableListView(created),
    forgotten: UnmodifiableListView(forgotten),
    updated: UnmodifiableListView(updated),
  );
}

class RealWorld extends StatelessWidget {
  const RealWorld({
    Key key,
    this.children,
    this.onInit,
    this.onDispose,
    this.onUpdate,
  }) : super(key: key);

  final List<Widget> children;
  final ValueChanged<InitState> onInit;
  final ValueChanged<Dispose> onDispose;
  final ValueChanged<DidUpdate> onUpdate;

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: children.map((child) {
            final index = i++;
            return NotificationListener<_Details>(
              onNotification: (notification) {
                print('hello world  $notification');
                notification
                  ..index = index
                  ..widget = child;
                if (notification is InitState) onInit?.call(notification);
                if (notification is Dispose) {
                  print('onDispose $onDispose ');
                  onDispose?.call(notification);
                }
                if (notification is DidUpdate) onUpdate?.call(notification);
                return true;
              },
              child: child,
            );
          }).toList(),
        ),
      ),
    );
  }
}

mixin _Details on Notification {
  int index;
  Widget widget;
}

class InitState extends Notification with _Details {}

class Dispose extends Notification with _Details {}

class DidUpdate extends Notification with _Details {}

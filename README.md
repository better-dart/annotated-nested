
# annotated-log.md

- https://github.com/better-dart/annotated-nested
- nested 源码分析
- `provider` 的 核心依赖包, 单文件, 源码很精简.

## annotated log:

- please check here: [annotated-log.md](./annotated-log.md)
- 详细源码分析记录.

## 关于 flutter provider 源码分析: 

- 因为需要分析 `provider` 源码, 才来分析 `nested`.
- 关于 provider 的源码分析: https://github.com/better-dart/annotated-provider






🚀

🚀

🚀

🚀

🚀

🚀

🚀

🚀

🚀

🚀


[![Build Status](https://travis-ci.org/rrousselGit/nested.svg?branch=master)](https://travis-ci.org/rrousselGit/nested)
[![pub package](https://img.shields.io/pub/v/nested.svg)](https://pub.dartlang.org/packages/nested) [![codecov](https://codecov.io/gh/rrousselGit/nested/branch/master/graph/badge.svg)](https://codecov.io/gh/rrousselGit/nested)

A widget that simplifies the syntax for deeply nested wodget trees.

## Motivation

Widgets tends to get pretty nested rapidly.
It's not rare to see:

```dart
MyWidget(
  child: AnotherWidget(
    child: Again(
      child: AndAgain(
        child: Leaf(),
      )
    )
  )
)
```

That's not very ideal.

There's where `nested` propose a solution.
Using `nested`, it is possible to flatten thhe previous tree into:

```dart
Nested(
  children: [
    MyWidget(),
    AnotherWidget(),
    Again(),
    AndAgain(),
  ],
  child: Leaf(),
),
```

That's a lot more readable!

## Usage

`Nested` relies on a new kind of widget: [SingleChildWidget], which has two
concrete implementation:

- [SingleChildStatelessWidget]
- [SingleChildStatefulWidget]

These are [SingleChildWidget] variants of the original `Stateless`/`StatefulWidget`.

The difference between a widget and its single-child variant is that they have
a custom `build` method that takes an extra parameter.

As such, a `StatelessWidget` would be:

```dart
class MyWidget extends StatelessWidget {
  MyWidget({Key key, this.child}): super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SomethingWidget(child: child);
  }
}
```

Whereas a [SingleChildStatelessWidget] would be:

```dart
class MyWidget extends SingleChildStatelessWidget {
  MyWidget({Key key, Widget child}): super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return SomethingWidget(child: child);
  }
}
```

This allows our new `MyWidget` to be used both with:

```dart
MyWidget(
  child: AnotherWidget(),
)
```

and to be placed inside `children` of [Nested] like so:

```dart
Nested(
  children: [
    MyWidget(),
    ...
  ],
  child: AnotherWidget(),
)
```

[singlechildwidget]: https://pub.dartlang.org/documentation/nexted/latest/nexted/SingleChildWidget-class.html
[singlechildstatelesswidget]: https://pub.dartlang.org/documentation/nexted/latest/nexted/SingleChildStatelessWidget-class.html
[singlechildstatefulwidget]: https://pub.dartlang.org/documentation/nexted/latest/nexted/SingleChildStatefulWidget-class.html

library xml_layout;

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;
import 'parser.dart';
import 'exceptions.dart';
import 'status.dart';
import 'template.dart';
import 'types/function.dart' as function;
import 'types/proxy.dart' as proxy;

part 'node.dart';


typedef MethodConstructor = dynamic Function();
typedef _NodeTester = bool Function(NodeData);
typedef ApplyFunction = dynamic Function(String name, List args);

class _Range {
  int start;
  int end;
  String value;
  _Range(this.start, this.end, this.value);
}



abstract class _ItemInfo {
  _ItemInfo();

  dynamic constructor(NodeData node, Key key);
}

class _ConstructorItemInfo extends _ItemInfo {
  ItemConstructor _constructor;

  _ConstructorItemInfo(this._constructor);

  @override
  constructor(NodeData node, Key key) {
    return _constructor(node, key);
  }
}

typedef InlineItemConstructor = Function(NodeData node, MethodNode method);

class _InlineItemData {
  String name;
  bool field;

  InlineItemConstructor constructor;
}

class _InlineItemInfo extends _ItemInfo {

  List<_InlineItemData> dataList = [];

  _InlineItemData _find(String name, bool field) {
    for (var data in dataList) {
      if (data.name == name && data.field == field) {
        return data;
      }
    }
    return null;
  }

  @override
  constructor(NodeData node, Key key) {
    if (node.text.contains('(')) {
      var method = MethodNode.parse(node.text, node.status);
      return _find(method.name, false)?.constructor?.call(node, method);
    } else {
      return _find(node.text, true)?.constructor?.call(node, null);
    }
  }
}

class XmlLayout extends StatefulWidget {
  static Map<dynamic, _ItemInfo> _constructors = Map();

  final xml.XmlElement element;
  final String template;
  final Map<String, dynamic> objects;
  final ItemConstructor onUnkownElement;

  static bool _initialized = false;

  /// Constructs a XmlLayout widget
  ///
  /// [template] is the xml string to build widget.
  /// [objects] parameters will be pass to builder.
  /// [apply] handle the invoke from XmlLayout widget.
  /// [onUnkownElement] handle unkown element
  ///
  /// Example:
  ///
  /// ```dart
  /// XmlLayout(
  ///   template: "<Text>$counter</Text>",
  ///   objects: {"counter": _counter},
  /// );
  /// ```
  ///
  XmlLayout(
      {Key key, @required this.template, this.objects, this.onUnkownElement})
      : element = null,
        super(key: key) {
    assert(template != null);
    _initialize();
  }

  /// Constructs a XmlLayout widget
  ///
  /// use a [XmlElement] to constructs a widget.
  XmlLayout.element(
      {Key key, @required this.element, this.objects, this.onUnkownElement})
      : template = null,
        super(key: key) {
    assert(element != null);
    _initialize();
  }

  static void _initialize() {
    if (!_initialized) {
      function.register();
      proxy.register();
      function.registerReturnType<Widget>();
      _initialized = true;
    }
  }

  @override
  State<StatefulWidget> createState() => XmlLayoutState()..onUnkown = onUnkownElement;

  static Iterable<String> get registerTypes {
    Map<String, String> types = Map();
    void add(String type) {
      String lower = type.toLowerCase();
      if (!types.containsKey(lower))
        types[lower] = type;
    }

    List<String> strArr = [];
    for (var type in _constructors.keys) {
      if (type is Type) {
        add(type.toString());
      } else if (type is String) {
        strArr.add(type);
      }
    }

    for (var type in strArr) {
      var arr = type.split(".");
      add(arr[0]);
    }
    return types.values;
  }

  /// Register a constructor method, which is used to convert
  /// xml tag to a dart Object
  static void register(String name, ItemConstructor constructor) {
    _constructors[name.toLowerCase()] = _ConstructorItemInfo(constructor);
  }

  /// Shortcat to register a enum type.
  ///
  /// Example:
  ///
  /// ```dart
  /// XmlLayout.registerEnum(Brightness.values);
  /// ```
  static void registerEnum<T>(List<T> values) {
    Map<String, T> map = Map();
    values.forEach((element) {
      map[element.toString().split(".").last] = element;
    });
    _constructors[T] = _ConstructorItemInfo((node, _) {
      String name = node.text;
      return map[name];
    });
  }

  /// Register a constructor method, which is used to convert
  /// a attribute data to a Object.
  static void registerInline(Type type, String name, bool field, InlineItemConstructor constructor) {
    var item = _constructors[type];
    if (item == null) {
      _constructors[type] = item = _InlineItemInfo();
    }
    if (item is _InlineItemInfo) {
      item.dataList.add(_InlineItemData()
          ..name = name
          ..field = field
          ..constructor = constructor
      );
    } else {
      throw "Target is not a inline item";
    }
  }

  /// Register a method
  ///
  /// The method can be used in the Xml attribute or the Script tag.
  ///
  /// Example:
  ///
  /// ```xml
  /// <if candidate="equal(1, mod($item, 2))">
  ///   <Text>Test</Text>
  /// </if>
  /// ```
  static void registerInlineMethod(String name, MethodHandler handler) {
    registerMethod(name, handler);
  }

  static void registerFunctionReturn<T>([String name]) {
    function.registerReturnType<T>(name);
  }
}

///
/// If a element has a [id] attribute, you can use
/// [find] method to get the [GlobalKey] of built widget
/// by the id string.
///
class XmlLayoutState extends State<XmlLayout> with NodeControl {
  Template template;
  Status status;

  @override
  Widget build(BuildContext context) {
    if (template == null) {
      xml.XmlElement element =
          widget.element ?? xml.XmlDocument.parse(widget.template)?.firstChild;
      if (element != null) {
        template = Template(element);
      } else {
        throw TemplateException("Can not parse template.");
      }
    }

    status.data = widget.objects;
    dynamic tar = template.generate(status, this).first?.element();
    if (tar is Widget) {
      return tar;
    } else {
      throw NotWidgetException();
    }
  }

  @override
  void didUpdateWidget(XmlLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.template != widget.template ||
        oldWidget.element != widget.element) {
      template = null;
      keys.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    status = Status(widget.objects);
  }

}

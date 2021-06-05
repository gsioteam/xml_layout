library xml_layout;

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'parser.dart';
import 'exceptions.dart';
import 'types/function.dart' as function;
import 'types/proxy.dart' as proxy;

typedef ItemConstructor = dynamic Function(NodeData node, Key key);
typedef MethodConstructor = dynamic Function();
typedef _NodeTester = bool Function(NodeData);
typedef ApplyFunction = dynamic Function(String name, List args);

mixin _NodeControl {
  Map<String, GlobalKey> _keys = Map();

  GlobalKey _getKey(String id) {
    if (_keys.containsKey(id)) return _keys[id];
    return _keys[id] = GlobalKey();
  }

  GlobalKey find(String id) {
    return _keys[id];
  }

  Map<String, dynamic> get objects;
  ApplyFunction get apply;

  ItemConstructor onUnkown;
}

class _StopControl {
  bool isStop = false;
}

class _FlowControlData {
  _FlowControlData next;
  List<NodeData> process(NodeData temp, _NodeTester tester,
          [_StopControl stop]) =>
      [];

  _FlowControlData([this.next]);
}

class _ForControlData extends _FlowControlData {
  String item;
  String index;
  NodeData array;
  NodeData count;

  _ForControlData(NodeData node, _FlowControlData next) : super(next) {
    xml.XmlElement element = node.node as xml.XmlElement;
    item = element.getAttribute("item") ?? "item";
    index = element.getAttribute("index") ?? "index";
    xml.XmlNode fnode = element.getAttributeNode("array");
    array = fnode != null ? NodeData(fnode, node.control, node) : null;
    fnode = element.getAttributeNode("count");
    count = fnode != null ? NodeData(fnode, node.control, node) : null;
  }

  @override
  List<NodeData> process(NodeData temp, _NodeTester tester,
      [_StopControl stop]) {
    List<NodeData> res = [];
    stop ??= _StopControl();
    if (array != null) {
      Iterable arr = array.t<Iterable>();
      if (arr != null) {
        int idx = 0;
        for (dynamic data in arr) {
          if (stop.isStop) break;
          NodeData newNode = temp.clone({item: data, index: idx++});
          if (next == null) {
            if (tester != null) {
              bool isStop = tester(newNode);
              if (isStop)
                stop.isStop = true;
              else
                res.add(newNode);
            }
          } else {
            res.addAll(next.process(newNode, tester, stop));
          }
        }
      }
    } else if (count != null) {
      int len = count.t<int>();
      if (len != null) {
        for (int i = 0; i < len; ++i) {
          if (stop.isStop) break;
          NodeData newNode = temp.clone({item: i, index: i});
          if (next == null) {
            if (tester != null) {
              bool isStop = tester(newNode);
              if (isStop)
                stop.isStop = true;
              else
                res.add(newNode);
            }
          } else {
            res.addAll(next.process(newNode, tester, stop));
          }
        }
      }
    }
    return res;
  }
}

class _IfControlData extends _FlowControlData {
  NodeData candidate;

  _IfControlData(NodeData node, _FlowControlData next) : super(next) {
    xml.XmlElement element = node.node as xml.XmlElement;
    xml.XmlNode fnode = element.getAttributeNode("candidate");
    candidate = fnode != null ? NodeData(fnode, node.control, node) : null;
  }

  @override
  List<NodeData> process(NodeData temp, _NodeTester tester,
      [_StopControl stop]) {
    List<NodeData> res = [];
    stop ??= _StopControl();
    if (!stop.isStop) {
      if (candidate != null) {
        bool cand;
        MethodNode a;
        if ((a = candidate.splitMethod("isEmpty", 1)) != null) {
          cand = a[0].isEmpty;
        } else if ((a = candidate.splitMethod("isNotEmpty", 1)) != null) {
          cand = a[0].isNotEmpty;
        } else {
          cand = candidate.boolean;
        }
        if (cand) {
          if (tester != null) {
            bool isStop = tester(temp);
            if (isStop)
              stop.isStop = true;
            else
              res.add(temp);
          }
        }
      }
    }
    return res;
  }
}

class _Range {
  int start;
  int end;
  String value;
  _Range(this.start, this.end, this.value);
}

class NodeData {
  xml.XmlNode node;
  _NodeControl control;
  _FlowControlData _flow;
  Map<String, dynamic> _ext;
  NodeData _father;

  Map<String, List<NodeData>> _attributes;
  List<NodeData> _children;

  NodeData(this.node, this.control, [NodeData father]) : _father = father;

  void _setNode(String name, NodeData node) {
    name = name.toLowerCase();
    List<NodeData> list = _attributes[name];
    if (list == null) {
      list = List();
      _attributes[name] = list;
    }
    list.add(node);
  }

  void _processElement(xml.XmlElement element, {_FlowControlData flow}) {
    if (element.name.toString().toLowerCase() == "for") {
      flow = _ForControlData(NodeData(element, control, this), flow);
      for (xml.XmlNode node in element.children) {
        if (node is xml.XmlElement) {
          _processElement(node, flow: flow);
        }
      }
    } else if (element.name.toString().toLowerCase() == "if") {
      flow = _IfControlData(NodeData(element, control, this), flow);
      for (xml.XmlNode node in element.children) {
        if (node is xml.XmlElement) {
          _processElement(node, flow: flow);
        }
      }
    } else if (element.name.prefix == "attr") {
      List<xml.XmlElement> els = [];
      xml.XmlText text;
      for (xml.XmlNode node in element.children) {
        if (node is xml.XmlElement) {
          els.add(node);
        } else if (text == null && node is xml.XmlText) {
          text = node;
        }
      }

      if (els.length == 0) {
        _setNode(element.name.local, NodeData(text ?? xml.XmlText(""), control, this).._flow = flow);
      } else {
        els.forEach((el) {
          _setNode(element.name.local,
              NodeData(el, control, this).._flow = flow);
        });
      }
    } else if (element.name.prefix == null) {
      _children.add(NodeData(element, control, this).._flow = flow);
    } else if (element.name.prefix == "arg") {
      xml.XmlElement el;
      xml.XmlText text;
      for (xml.XmlNode node in element.children) {
        if (el == null && node is xml.XmlElement) {
          el = node;
        } else if (text == null && node is xml.XmlText) {
          text = node;
        }
      }

      _setNode(element.name.toString(),
          NodeData(el ?? text ?? xml.XmlText(""), control, this).._flow = flow);
    }
  }

  void _processChild() {
    if (_children == null) {
      _children = [];
      if (node is xml.XmlElement) {
        for (xml.XmlNode child in node.children) {
          if (child is xml.XmlElement) _processElement(child);
        }
      }
    }
  }

  NodeData clone(Map<String, dynamic> ext) {
    NodeData one = NodeData(node, control, _father);
    one._ext = ext ?? _ext;
    one._attributes = _attributes;
    one._children = _children?.map<NodeData>((element) {
      var child = element.clone(null);
      child._father = one;
      return child;
    })?.toList();
    return one;
  }

  void _processSubNode(NodeData subnode, bool Function(NodeData) handler) {
    if (subnode._flow == null) {
      handler(subnode);
    } else {
      subnode._flow.process(subnode, handler);
    }
  }

  NodeData _firstChild(List<NodeData> nodes, [bool Function(NodeData) tester]) {
    NodeData res;
    if (nodes != null) {
      for (NodeData subnode in nodes) {
        _processSubNode(subnode, (node) {
          if (tester == null || tester(node)) {
            res = node;
          }
          return true;
        });
        if (res != null) break;
      }
    }
    return res;
  }

  List<T> _convertListTo<T>(List<NodeData> nodes) {
    List<T> res = [];
    void addResult(NodeData node) {
      dynamic obj = node.t<T>();
      if (obj != null) res.add(obj);
    }

    for (NodeData node in nodes) {
      _processSubNode(node, (newNode) {
        addResult(newNode);
        return false;
      });
    }
    return res;
  }

  NodeData operator [](String name) {
    if (_attributes == null && node is xml.XmlElement) {
      xml.XmlElement element = node as xml.XmlElement;
      _attributes = Map();
      element.attributes.forEach((element) {
        if (element.name.prefix == null || element.name.prefix == "attr")
          _setNode(element.name.local, NodeData(element, control, this));
      });

      _processChild();
    }
    if (_attributes == null) return null;
    return _firstChild(_attributes[name.toLowerCase()]);
  }

  Key _getKey() {
    NodeData id = this["id"];
    Key key;
    if (id != null) {
      key = control._getKey(id.text);
    }
    return key;
  }

  dynamic element() {
    if (isElement) {
      xml.XmlElement element = this.node as xml.XmlElement;
      _ItemInfo info =
          XmlLayout._constructors[element.name.toString().toLowerCase()];
      if (info != null) {
        return info.constructor(this, _getKey());
      }
    }
  }

  String _processText(String text) {
    const String mark = r"$";
    const String slash = r"/";

    int off = text.indexOf(mark);
    List<_Range> ranges = [];
    while (off >= 0) {
      int slashCount = 0;
      int pre = off - 1;
      while (pre > 0 && text[pre] == slash) {
        ++slashCount;
        --pre;
      }

      if (slashCount % 2 == 0) {
        if (text[off + 1] == "{") {
          Match match =
              RegExp(r"(?<=\$)\{([^\}]+)\}").matchAsPrefix(text, off + 1);
          if (match != null) {
            ranges.add(_Range(match.start - 1, match.end, match.group(1)));
          } else {}
        } else {
          Match match = RegExp(r"(?<=\$)[\w_]+").matchAsPrefix(text, off + 1);
          if (match != null) {
            ranges.add(_Range(match.start - 1, match.end, match.group(0)));
          } else {}
        }
      }
      off = text.indexOf(mark, off + 1);
    }
    ranges.reversed.forEach((element) {
      text = text.replaceRange(
          element.start, element.end, _get(element.value).toString());
    });
    return text;
  }

  String _raw;
  String get raw =>
      _raw ??
      (_raw = node is xml.XmlAttribute
          ? (node as xml.XmlAttribute).value
          : node.text.trim());
  String get text => _processText(raw);
  int get integer => int.tryParse(text);
  double get real => double.tryParse(text);
  bool get boolean => text == "true";

  bool get isAttribute => node is xml.XmlAttribute;
  bool get isElement => node is xml.XmlElement;
  String get name =>
      node is xml.XmlElement ? (node as xml.XmlElement).name.local : null;

  T child<T>() {
    _processChild();
    if (_children != null) {
      T res;
      String text;
      if (_children.isEmpty && (text = this.text).isNotEmpty) {
        res = v<T>(text);
      } else {
        _firstChild(_children, (node) {
          dynamic obj = node.element();
          if (obj != null && obj is T) {
            res = obj;
            return true;
          } else {
            if (obj == null) {
              control.onUnkown?.call(node, node._getKey());
            }
            return false;
          }
        });
      }
      return res;
    }
    return null;
  }

  List<T> children<T>() {
    _processChild();

    return _children == null ? [] : _convertListTo<T>(_children);
  }

  List<T> array<T>(String name) {
    List<NodeData> attrs = _attributes[name.toLowerCase()];
    var attr = attrs?.first;
    if (attr == null) return null;
    else if (attr.isElement) {
      return _convertListTo<T>(attrs);
    } else {
      return attr.t<List<T>>();
    }
  }

  dynamic _get(String path) {
    RegExp exp = RegExp(r"^(\w+)((\[[^\]]+\])*)$");
    RegExp bExp = RegExp(r"\[([^\]]+)\]");
    List<String> arr = path.split(".");
    List segs = [];
    for (String seg in arr) {
      RegExpMatch match = exp.firstMatch(seg);
      if (match == null) return null;
      String name = match.group(1);
      String property = match.group(2);
      segs.add(name);
      if (property.length > 0) {
        var matches = bExp.allMatches(property);
        for (Match match in matches) {
          segs.add(jsonDecode(match.group(1)));
        }
      }
    }

    dynamic ret = _getPath(_ext, segs, 0);
    if (ret == null && control.objects != null) {
      ret = _getPath(control.objects, segs, 0);
    }
    if (ret == null) {
      NodeData father = _father;
      while (father != null) {
        ret = _getPath(father._ext, segs, 0);
        if (ret != null) break;
        father = father._father;
      }
    }
    return ret;
  }

  static _getPath(dynamic tar, List path, int offset) {
    if (offset >= path.length) {
      return tar;
    } else {
      dynamic seg = path[offset];
      if (tar is Map || tar is MapMixin) {
        var sub = seg is String ? tar[seg] : null;
        if (sub == null) return null;
        return _getPath(sub, path, offset + 1);
      } else if (tar is List || tar is ListMixin) {
        if (seg is int) {
          var sub = tar[seg];
          if (sub == null) return null;
          return _getPath(sub, path, offset + 1);
        } else
          return null;
      }
    }
  }

  static RegExp _matchRegExp1 = RegExp(r"^\$([\w_]+)$");
  static RegExp _matchRegExp2 = RegExp(r"^\$\{([^\}]+)\}$");
  T t<T>() {
    if (!isElement) {
      Match regExp = _matchRegExp1.firstMatch(raw);
      if (regExp == null) {
        regExp = _matchRegExp2.firstMatch(raw);
      }
      if (regExp != null) {
        dynamic obj = _get(regExp.group(1));
        if (obj is T) return obj;
        if (T == String) return obj.toString() as T;
      }
    }
    switch (T) {
      case String:
        {
          return text as T;
        }
      case bool:
        {
          return boolean as T;
        }
      case int:
        {
          return integer as T;
        }
      case double:
        {
          return real as T;
        }
      default:
        {
          if (isElement) {
            dynamic obj = element();
            if (obj is T)
              return obj;
            else
              return control.onUnkown?.call(this, _getKey());
          }
          _ItemInfo info = XmlLayout._constructors[T];
          if (info == null) {
            return control.onUnkown?.call(this, _getKey());
          } else {
            dynamic obj = info.constructor(this, _getKey());
            return obj;
          }
        }
    }
  }
  T convert<T>() => t<T>();

  T s<T>(String name, [T def]) => this[name]?.t<T>() ?? def;
  T attribute<T>(String attributeName, [T defaultValue]) => s<T>(name, defaultValue);

  T v<T>(String txt, [T def]) {
    _ItemInfo info = XmlLayout._constructors[T];
    return info.constructor(NodeData(xml.XmlText(txt), control, this), null) ?? def;
  }
  T value<T>(String value, [T defaultValue]) => v<T>(value, defaultValue);

  MethodNode _arguments;
  bool _argvInit = false;
  static const String MethodPattern = r"^{0}\(([^\)]*)\)$";
  MethodNode splitMethod(String name, int count) {
    if (!isElement) {
      if (!_argvInit) {
        _arguments = MethodNode.parse(text);
        _argvInit = true;
      }
      if (_arguments != null && _arguments.name == name && _arguments.length == count)
        return _arguments;
    }
    return null;
  }

  dynamic apply(String name, List args) {
    return control.apply?.call(name, args);
  }
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
  }

  @override
  constructor(NodeData node, Key key) {
    if (node.text.contains('(')) {
      var method = MethodNode.parse(node.text);
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
  final ApplyFunction apply;
  final ItemConstructor onUnkownElement;

  static bool _initialized = false;

  /**
   * Constructs a XmlLayout widget
   *
   * [template] is the xml string to build widget.
   * [objects] parameters will be pass to builder.
   * [apply] handle the invoke from XmlLayout widget.
   * [onUnkownElement] handle unkown element
   *
   * Example:
   *
   * ```dart
   * XmlLayout(
   *   template: "<Text>$counter</Text>",
   *   objects: {"counter": _counter},
   * );
   * ```
   *
   */
  XmlLayout(
      {Key key, @required this.template, this.objects, this.apply, this.onUnkownElement})
      : element = null,
        super(key: key) {
    assert(template != null);
    _initialize();
  }

  /**
   * Constructs a XmlLayout widget
   *
   * use a [XmlElement] to constructs a widget.
   */
  XmlLayout.element(
      {Key key, @required this.element, this.objects, this.apply, this.onUnkownElement})
      : template = null,
        super(key: key) {
    assert(element != null);
    _initialize();
  }

  static void _initialize() {
    if (!_initialized) {
      function.register();
      proxy.register();
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

  /**
   * Register a constructor method, which is used to convert
   * xml tag to a dart Object
   */
  static void register(String name, ItemConstructor constructor) {
    _constructors[name.toLowerCase()] = _ConstructorItemInfo(constructor);
  }

  /**
   * Shortcat to register a enum type.
   *
   * Example:
   *
   * ```dart
   * XmlLayout.registerEnum(Brightness.values);
   * ```
   */
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

  /**
   * Register a constructor method, which is used to convert
   * a attribute data to a Object.
   */
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
}

/**
 *
 * If a element has a [id] attribute, you can use
 * [find] method to get the [GlobalKey] of built widget
 * by the id string.
 *
 */
class XmlLayoutState extends State<XmlLayout> with _NodeControl {
  NodeData _data;

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      xml.XmlElement element =
          widget.element ?? xml.XmlDocument.parse(widget.template)?.firstChild;
      if (element != null) {
        _data = NodeData(element, this);
      } else {
        throw TemplateException("Can not parse template.");
      }
    }

    dynamic tar = _data.element();
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
      _data = null;
      _keys.clear();
    }
  }

  @override
  Map<String, dynamic> get objects => widget.objects;
  @override
  ApplyFunction get apply => widget.apply;
}

class XmlLayoutBuilder with _NodeControl {
  NodeData _data;
  Map<String, GlobalKey> _keys = Map();
  String template;
  xml.XmlElement element;
  Map<String, dynamic> _objects;
  ApplyFunction _apply;

  Widget build(BuildContext context,
      {Map<String, dynamic> objects,
      String template,
      xml.XmlElement element,
      ItemConstructor onUnkownElement,
      ApplyFunction apply}) {
    XmlLayout._initialize();
    onUnkown = onUnkownElement;
    _objects = objects;
    _apply = apply;
    if (template != this.template) {
      this.template = template;
      _data = null;
    }
    if (this.element != element) {
      this.element = element;
      _data = null;
    }
    if (_data == null) {
      xml.XmlElement el =
          element ?? xml.XmlDocument.parse(template)?.firstChild;
      if (el != null) {
        _data = NodeData(el, this);
      } else {
        throw TemplateException("Can not parse template.");
      }
    }

    dynamic tar = _data.element();
    if (tar is Widget) {
      return tar;
    } else {
      throw NotWidgetException();
    }
  }

  GlobalKey find(String id) {
    return _keys[id];
  }

  @override
  Map<String, dynamic> get objects => _objects;

  @override
  ApplyFunction get apply => _apply;
}

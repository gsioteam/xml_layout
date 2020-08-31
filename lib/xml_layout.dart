library xml_layout;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'parser.dart';
import 'exceptions.dart';
import 'types.dart';

typedef ItemConstructor = dynamic Function(NodeData node, Key key);
typedef MethodConstructor = dynamic Function();
typedef _NodeTester = bool Function(NodeData);

class _StopControl {
  bool isStop = false;
}

class _FlowControlData {
  _FlowControlData next;
  List<NodeData> process(NodeData temp, _NodeTester tester, [_StopControl stop]) => [];

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
    array = fnode != null ? NodeData(fnode, node.state, node) : null;
    fnode = element.getAttributeNode("count");
    count = fnode != null ? NodeData(fnode, node.state, node) : null;
  }

  @override
  List<NodeData> process(NodeData temp, _NodeTester tester, [_StopControl stop]) {
    List<NodeData> res = [];
    stop ??= _StopControl();
    if (array != null) {
      Iterable arr = array.t<Iterable>();
      if (arr != null) {
        int idx = 0;
        for (dynamic data in arr) {
          if (stop.isStop) break;
          NodeData newNode = temp.clone({
            item: data,
            index: idx++
          });
          if (next == null) {
            if (tester != null) {
              bool isStop = tester(newNode);
              if (isStop) stop.isStop = true;
              else res.add(newNode);
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
          NodeData newNode = temp.clone({
            item: i,
            index: i
          });
          if (next == null) {
            if (tester != null) {
              bool isStop = tester(newNode);
              if (isStop) stop.isStop = true;
              else res.add(newNode);
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
    candidate = fnode != null ? NodeData(fnode, node.state, node) : null;
  }

  @override
  List<NodeData> process(NodeData temp, _NodeTester tester, [_StopControl stop]) {
    List<NodeData> res = [];
    stop ??= _StopControl();
    if (!stop.isStop) {
      if (candidate != null) {
        bool cand = candidate.t<bool>();
        if (cand) {
          if (tester != null) {
            bool isStop = tester(temp);
            if (isStop) stop.isStop = true;
            else res.add(temp);
          }
        }
      }
    }
    return res;
  }
}

class _PathSegment {

}

class _Range {
  int start;
  int end;
  String value;
  _Range(this.start, this.end, this.value);
}

class NodeData {
  xml.XmlNode node;
  XmlLayoutState state;
  _FlowControlData _flow;
  Map<String, dynamic> _ext;
  NodeData _father;

  Map<String, List<NodeData>> _attributes;
  List<NodeData> _children;

  NodeData(this.node, this.state, [NodeData father]) : _father = father;

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
      flow = _ForControlData(NodeData(element, state, this), flow);
      for (xml.XmlNode node in element.children) {
        if (node is xml.XmlElement) {
          _processElement(node, flow: flow);
        }
      }
    }
    else if (element.name.toString().toLowerCase() == "if") {
      flow = _IfControlData(NodeData(element, state, this), flow);
      for (xml.XmlNode node in element.children) {
        if (node is xml.XmlElement) {
          _processElement(node, flow: flow);
        }
      }
    }
    else if (element.name.prefix == "attr") {
      xml.XmlElement el;
      xml.XmlText text;
      for (xml.XmlNode node in element.children) {
        if (el == null && node is xml.XmlElement) {
          el = node;
        } else if (text == null && node is xml.XmlText) {
          text = node;
        }
      }

      _setNode(element.name.local,
        NodeData(el ?? text ?? xml.XmlText(""), state, this)
          .._flow = flow
      );
    }
    else if (element.name.prefix == null) {
      _children.add(
        NodeData(element, state, this)
          .._flow = flow
      );
    }
  }

  void _processChild() {
    if (_children == null) {
      _children = [];
      if (node is xml.XmlElement) {
        for (xml.XmlNode child in node.children) {
          if (child is xml.XmlElement)
            _processElement(child as xml.XmlElement);
        }
      }
    }
  }

  NodeData clone(Map<String, dynamic> ext) {
    NodeData one = NodeData(node, state, _father);
    one._ext = ext;
    one._attributes = _attributes;
    one._children = _children;
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
          _setNode(element.name.local, NodeData(element, state, this));
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
      key = state._getKey(id.text);
    }
    return key;
  }

  dynamic element() {
    if (isElement) {
      xml.XmlElement element = this.node as xml.XmlElement;
      _ItemInfo info =
          XmlLayout._constructors[element.name.toString().toLowerCase()];
      if (info != null && info.mode & XmlLayout.Element != 0) {
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
          Match match = RegExp(r"(?<=\$)\{([^\}]+)\}").matchAsPrefix(text, off + 1);
          if (match != null) {
            ranges.add(_Range(match.start - 1, match.end, match.group(1)));
          } else {

          }
        } else {
          Match match = RegExp(r"(?<=\$)[\w_]+").matchAsPrefix(text, off + 1);
          if (match != null) {
            ranges.add(_Range(match.start - 1, match.end, match.group(0)));
          } else {

          }
        }
      }
      off = text.indexOf(mark, off + 1);
    }
    ranges.reversed.forEach((element) {
      text = text.replaceRange(element.start, element.end, _get(element.value).toString());
    });
    return text;
  }

  String _raw;
  String get raw => _raw ?? (_raw = node is xml.XmlAttribute ? (node as xml.XmlAttribute).value : node.text);
  String get text => _processText(raw);
  int get integer => int.tryParse(text);
  double get real => double.tryParse(text);
  bool get boolean => text == "true" ? true : false;

  bool get isAttribute => node is xml.XmlAttribute;
  bool get isElement => node is xml.XmlElement;
  String get name =>
      node is xml.XmlElement ? (node as xml.XmlElement).name.local : null;

  T child<T>() {
    _processChild();
    if (_children != null) {
      T res;
      _firstChild(_children, (node) {
        dynamic obj = node.element();
        if (obj is T) {
          res = obj;
          return true;
        } else return false;
      });
      return res;
    }
    return null;
  }

  List<T> children<T>() {
    _processChild();

    return _children == null ? [] : _convertListTo<T>(_children);
  }

  List<T> arr<T>(String name) {
    List<NodeData> attr = _attributes[name.toLowerCase()];

    return attr == null ? [] : _convertListTo<T>(attr);
  }

  dynamic _get(String path) {
    RegExp exp = RegExp(r"^(\w+)((\[[^\]]+\])*)$");
    RegExp bExp = RegExp(r"\[([^\]]+)\]");
    List<String> arr = path.split(".");
    List segs  = [];
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
    if (ret == null && state.widget?.objects != null) {
      ret = _getPath(state.widget.objects, segs, 0);
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
    }  else {
      dynamic seg = path[offset];
      if (tar is Map) {
        var sub = seg is String ? tar[seg] : null;
        if (sub == null) return null;
        return _getPath(sub, path, offset + 1);
      } else if (tar is List) {
        if (seg is int) {
          var sub = tar[seg];
          if (sub == null) return null;
          return _getPath(sub, path, offset + 1);
        }
        else return null;
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
          _ItemInfo info = XmlLayout._constructors[T];
          if (info == null) {
            dynamic obj = element();
            if (obj is T) return obj;
            else return null;
          } else {
            bool check = false;
            check |= info.mode & XmlLayout.Element > 0 && isElement;
            check |= info.mode & XmlLayout.Text > 0 && !isElement;
            dynamic obj;
            if (check) {
              obj = info.constructor(this, _getKey());
            }
            return obj;
          }
        }
    }
  }

  T s<T>(String name, [T def]) {
    return this[name]?.t<T>() ?? def;
  }

  T v<T>(String txt) {
    _ItemInfo info = XmlLayout._constructors[T];
    if (info.mode & XmlLayout.Text > 0) {
      return info.constructor(NodeData(xml.XmlText(txt), state, this), null);
    }
    return null;
  }

  MethodNode _arguments;
  bool _argvInit = false;
  static const String MethodPattern = r"^{0}\(([^\)]*)\)$";
  MethodNode splitMethod(String name, int count) {
    if (!isElement) {
      if (!_argvInit) {
        _arguments = MethodNode.parse(node.text);
      }
      return _arguments;
    }
    return null;
  }
}

class _ItemInfo {
  ItemConstructor constructor;
  int mode;

  _ItemInfo(this.constructor, this.mode);
}

// TODO: better?
bool _initialized = false;

class XmlLayout extends StatefulWidget {
  static Map<dynamic, _ItemInfo> _constructors = Map();

  static const Element = 1, Text = 2;

  final xml.XmlElement element;
  final String template;
  final Map<String, dynamic> objects;

  XmlLayout({Key key, @required this.template, this.objects})
      : element = null,
        super(key: key) {
    assert(template != null);
    if (!_initialized) {
      initTypes();
      _initialized = true;
    }
  }

  XmlLayout.element({
    Key key,
    @required this.element,
    this.objects,
  })  : template = null,
        super(key: key) {
    assert(element != null);
  }

  @override
  State<StatefulWidget> createState() => XmlLayoutState();

  static void reg(dynamic nameOrType, ItemConstructor constructor,
      {int mode = Element | Text}) {
    assert(mode != null);
    if (nameOrType is String) mode = Element;
    dynamic info = _ItemInfo(constructor, mode);
    if (nameOrType is Type) {
      _constructors[nameOrType] = info;
      nameOrType = nameOrType.toString();
    }
    _constructors[nameOrType.toLowerCase()] = info;
  }

  static void regEnum<T>(List<T> values) {
    Map<String, T> map = Map();
    values.forEach((element) {
      map[element.toString().split(".").last] = element;
    });
    reg(T, (node, _) {
      String name = node.text;
      return map[name];
    }, mode: Text);
  }
}

class XmlLayoutState extends State<XmlLayout> {
  NodeData _data;
  Map<String, GlobalKey> _keys = Map();

  GlobalKey _getKey(String id) {
    if (_keys.containsKey(id)) return _keys[id];
    return _keys[id] = GlobalKey();
  }

  GlobalKey find(String id) {
    return _keys[id];
  }

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
}

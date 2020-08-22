
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'exceptions.dart';
import 'types.dart';

typedef ItemConstructor = dynamic Function(NodeData node, Key key);
typedef MethodConstructor = dynamic Function();

class NodeData {
  xml.XmlNode node;
  XMLLayoutState state;

  Map<String, List<NodeData> > _attributes;
  List<NodeData> _children;

  NodeData(this.node, this.state);

  void _setNode(String name, NodeData node) {
    name = name.toLowerCase();
    List<NodeData> list = _attributes[name];
    if (list == null) {
      list = List();
      _attributes[name] = list;
    }
    list.add(node);
  }

  NodeData operator[](String name) {
    if (_attributes == null && node is xml.XmlElement) {
      xml.XmlElement element = node as xml.XmlElement;
      _attributes = Map();
      element.attributes.forEach((element) {
        if (element.name.namespaceUri == null || element.name.namespaceUri == "attr")
          _setNode(element.name.local, NodeData(element, state));
      });

      element.children.forEach((element) {
        if (element is xml.XmlElement && element.name.namespaceUri == "attr") {
          xml.XmlElement el;
          xml.XmlText text;
          for (xml.XmlNode node in element.children) {
            if (el == null && node is xml.XmlElement) {
              el = node;
            } else if (text == null && node is xml.XmlText) {
              text = node;
            }
          }

          _setNode(element.name.local, NodeData(el ?? text ?? xml.XmlText(""), state));
        }
      });
    }
    List<NodeData> ret = _attributes[name.toLowerCase()];
    return ret?.first;
  }

  Key _getKey() {
    NodeData id = this["id"];
    Key key;
    if (id != null) {
      key = state._addKey(id.text);
    }
    return key;
  }

  dynamic element() {
    if (isElement) {
      xml.XmlElement element = this.node as xml.XmlElement;
      _ItemInfo info = XMLLayout._constructors[element.name.toString().toLowerCase()];
      if (info != null && info.mode & XMLLayout.Element != 0) {
        return info.constructor(this, _getKey());
      }
    }
  }

  String get text => node is xml.XmlAttribute ? (node as xml.XmlAttribute).value : node.text;
  int get integer => int.parse(text);
  double get real => double.parse(text);
  bool get boolean => text == "true" ? true:false;

  bool get isAttribute => node is xml.XmlAttribute;
  bool get isElement => node is xml.XmlElement;
  String get name => node is xml.XmlElement ? (node as xml.XmlElement).name.local : null;

  void _init() {
    if (children == null) {
      _children = [];
      if (node is xml.XmlElement) {
        xml.XmlElement element = node as xml.XmlElement;

        element.children.forEach((element) {
          if (element is xml.XmlElement && element.name.namespaceUri == null) {
            _children.add(NodeData(element, state));
          }
        });
      }
    }
  }

  T child<T>() {
    _init();
    for (NodeData data in _children) {
      dynamic obj = _children.first?.element();
      if (obj is T) return obj;
    }
    return null;
  }

  List<T> children<T>() {
    _init();
    List<T> ret = [];
    _children.forEach((element) {
      dynamic obj = element.element();
      if (obj is T) ret.add(obj);
    });
    return ret;
  }

  Function fn(String name) {
    return state.widget.functions[name];
  }

  List<T> arr<T>(String name) {
    List<NodeData> attr = _attributes[name.toLowerCase()];
    List<T> ret = [];
    attr?.forEach((element) {
      dynamic obj = element.t<T>();
      if (obj != null) ret.add(obj);
    });
    return ret;
  }

  T t<T>() {
    switch (T) {
      case Function: {
        if (isAttribute && text != null) {
          return fn(text) as T;
        }
        return null;
      }
      case String: {
        return text as T;
      }
      case bool: {
        return boolean as T;
      }
      case int: {
        return integer as T;
      }
      case double: {
        return real as T;
      }
      default: {
        _ItemInfo info = XMLLayout._constructors[T];
        bool check = false;
        check |= info.mode & XMLLayout.Element > 0 && isElement;
        check |= info.mode & XMLLayout.Text > 0 && !isElement;
        if (check) {
          return info.constructor(this, _getKey());
        }
        return null;
      }
    }
  }

  T s<T>(String name) {
    return this[name]?.t<T>();
  }

  T v<T>(String txt) {
    _ItemInfo info = XMLLayout._constructors[T];
    if (info.mode & XMLLayout.Text > 0) {
      return info.constructor(NodeData(xml.XmlText(txt), state), null);
    }
    return null;
  }

  static const String MethodPattern = r"^{0}\(([^\)]*)\)$";
  List<String> splitMethod(String name, int count) {
    if (!isElement) {
      String str = MethodPattern.replaceFirst("{0}", name);
      var matches = RegExp(str).allMatches(node.text);
      if (matches.isNotEmpty) {
        var params = matches.first.group(1).split(",");
        if (params.length == count) {
          return List.from(params.map<String>((e) => e.trim()));
        } else if (count == 0 && params.first.isEmpty) {
          return [];
        } else {
          print("${node.text} params count not match $count}");
        }
      }
    }
  }


}

class _ItemInfo {
  ItemConstructor constructor;
  int mode;

  _ItemInfo(this.constructor, this.mode);
}

class XMLLayout extends StatefulWidget {
  static Map<dynamic, _ItemInfo> _constructors = Map();

  static const Element = 1, Text = 2;

  String temp;
  Map<String, Function> functions;

  static bool _firstInit = true;

  XMLLayout({this.temp, this.functions}) {
    if (this.functions == null) this.functions = Map();
    if (_firstInit) {
      initTypes();
      _firstInit = false;
    }
  }

  @override
  State<StatefulWidget> createState() => XMLLayoutState();

  static void reg(dynamic nameOrType, ItemConstructor constructor, {
    int mode = Element | Text
  }) {
    assert(mode != null);
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

class XMLLayoutState extends State<XMLLayout> {
  Widget _build;
  Map<String, GlobalKey> _keys = Map();

  @override
  Widget build(BuildContext context) {
    if (_build == null) {
      xml.XmlDocument doc = xml.parse(widget.temp);
      if (doc.firstChild != null) {
        NodeData data = NodeData(doc.firstChild, this);
        dynamic tar = data.element();
        if (tar is Widget) {
          _build = tar;
        } else {
          throw NotWidgetException();
        }
      } else {
        throw TemplateException("Can not parse template.");
      }
    }
    return _build;
  }

  GlobalKey _addKey(String id) {
    return _keys[id] = GlobalKey();
  }
}

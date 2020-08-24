
library xml_layout;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'parser.dart';
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
        if (element.name.prefix == null || element.name.prefix == "attr")
          _setNode(element.name.local, NodeData(element, state));
      });

      element.children.forEach((element) {
        if (element is xml.XmlElement && element.name.prefix == "attr") {
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
    return _attributes != null ? _attributes[name.toLowerCase()]?.first : null;
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
    if (_children == null) {
      _children = [];
      if (node is xml.XmlElement) {
        xml.XmlElement element = node as xml.XmlElement;

        element.children.forEach((element) {
          if (element is xml.XmlElement && element.name.prefix == null) {
            _children.add(NodeData(element, state));
          }
        });
      }
    }
  }

  T child<T>() {
    _init();
    if (_children != null) {
      for (NodeData data in _children) {
        dynamic obj = data.element();
        if (obj is T) return obj;
      }
    }
    return null;
  }

  List<T> children<T>() {
    _init();
    List<T> ret = [];
    _children?.forEach((element) {
      dynamic obj = element.element();
      if (obj is T) ret.add(obj);
    });
    return ret;
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
    if (!isElement) {
      if (text[0] == r'$') {
        dynamic obj = state.widget.objects[text.substring(1)];
        if (obj != null) {
          if (obj is T) return obj;
          if (T == String) return obj.toString() as T;
        }
      }
    }
    switch (T) {
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
        dynamic obj;
        if (check) {
          obj = info.constructor(this, _getKey());
        }
        if (obj == null && !isElement) {
          obj = state.widget.objects[text];
          if (!(obj is T)) obj = null;
        }
        return obj;
      }
    }
  }

  T s<T>(String name, [T def]) {
    return this[name]?.t<T>() ?? def;
  }

  T v<T>(String txt) {
    _ItemInfo info = XMLLayout._constructors[T];
    if (info.mode & XMLLayout.Text > 0) {
      return info.constructor(NodeData(xml.XmlText(txt), state), null);
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

class XMLLayout extends StatefulWidget {
  static Map<dynamic, _ItemInfo> _constructors = Map();

  static const Element = 1, Text = 2;

  String temp;
  Map<String, dynamic> objects;

  static bool _firstInit = true;

  XMLLayout({
    Key key,
    this.temp,
    this.objects
  }) : super(key: key) {
    if (this.objects == null) this.objects = Map();
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

class XMLLayoutState extends State<XMLLayout> {
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
      xml.XmlDocument doc = xml.parse(widget.temp);
      if (doc.firstChild != null) {
        _data = NodeData(doc.firstChild, this);
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
  void didUpdateWidget(XMLLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.temp != widget.temp) {
      _data = null;
      _keys.clear();
    }
  }

}

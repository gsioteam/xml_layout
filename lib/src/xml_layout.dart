
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'exceptions.dart';
import 'types.dart';

typedef ItemConstructor = dynamic Function(NodeData node, Key key);
typedef TypeConverter = dynamic Function(NodeData node);

class NodeData {
  xml.XmlNode node;
  XMLLayoutState state;

  Map<String, List<NodeData> > _attributes;
  List<NodeData> _children;

  NodeData(this.node, this.state);

  void _setNode(String name, NodeData node) {
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

  dynamic object() {
    if (this.node is xml.XmlElement) {
      xml.XmlElement element = this.node as xml.XmlElement;
      ItemConstructor constructor = XMLLayout._constructors[element.name];
      if (constructor != null) {
        NodeData id = this["id"];
        Key key;
        if (id != null) {
          key = state._addKey(id.text);
        }
        return constructor(this, key);
      }
    }
  }

  String get text => node is xml.XmlAttribute ? (node as xml.XmlAttribute).value : node.text;
  int get integer => int.parse(text);
  double get real => double.parse(text);
  bool get boolean => text == "true" ? true:false;

  bool get isAttribute => node is xml.XmlAttribute;
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

  Widget get child {
    _init();
    dynamic obj = _children.first?.object();
    return obj is Widget ? obj : null;
  }

  List<Widget> get children {
    _init();
    List<Widget> ret = [];
    _children.forEach((element) {
      dynamic obj = element.object();
      if (obj is Widget) ret.add(obj);
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
        if (text != null) {
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
        TypeConverter covert = XMLLayout._types[T];
        dynamic obj;
        if (covert != null) {
          obj = covert(this);
        }
        if (obj == null) {
          obj = object();
          if (obj is T) return obj;
          else return null;
        } else return obj;
      }
    }
  }

  T s<T>(String name) {
    return this[name]?.t<T>();
  }
}

class XMLLayout extends StatefulWidget {
  static Map<String, ItemConstructor> _constructors = Map();
  static Map<Type, TypeConverter> _types = Map();

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

  static void reg(dynamic nameOrType, ItemConstructor constructor) {
    if (nameOrType is Type) nameOrType = nameOrType.toString();
    _constructors[nameOrType.toLowerCase()] = constructor;
  }

  static void regType(Type type, TypeConverter converter) {
    _types[type] = converter;
  }

  static void regEnum<T>(List<T> values) {
    Map<String, T> map = Map();
    values.forEach((element) {
      map[element.toString().split(".").last] = element;
    });
    regType(T, (node) {
      String name = node.text;
      return map[name];
    });
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
        dynamic tar = data.object();
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


part of xml_layout;

typedef ItemConstructor = dynamic Function(NodeData node, Key key);

mixin NodeControl {
  Map<String, GlobalKey> keys = Map();

  GlobalKey _getKey(String id) {
    if (keys.containsKey(id)) return keys[id];
    return keys[id] = GlobalKey();
  }

  GlobalKey find(String id) {
    return keys[id];
  }

  ItemConstructor onUnkown;
}

class NodeData {
  Template _template;
  Status _status;
  NodeControl control;
  NodeData _father;

  Map<String, List<NodeData>> _attributes;
  List<NodeData> _children;
  List<String> _text;

  Status get status => _status;

  NodeData(this._template, this._status, this.control);

  void _setNode(String name, NodeData node) {
    name = name.toLowerCase();
    List<NodeData> list = _attributes[name];
    if (list == null) {
      list = [];
      _attributes[name] = list;
    }
    list.add(node);
  }

  List<NodeData> _rawChildren;
  List<NodeData> get rawChildren {
    if (_rawChildren == null) {
      _rawChildren = [];
      if (_template.node is xml.XmlElement) {
        for (var childTemplate in _template.children) {
          _rawChildren.addAll(childTemplate.generate(status, control));
        }
      }
    }
    return _rawChildren;
  }

  void _processNode() {
    if (_children == null) {
      _attributes = {};
      _children = [];
      _text = [];
      if (_template.node is xml.XmlElement) {
        for (var attr in _template.attributes) {
          _setNode(attr.name.local, NodeData(attr, _status, control));
        }

        for (var child in rawChildren) {
          if (child.name?.prefix == "attr") {
            for (var sub in child.rawChildren) {
              _setNode(child.name.local, sub);
            }
          } else if (child.name?.prefix == "arg") {
            for (var sub in child.rawChildren) {
              _setNode(child.name.toString(), sub);
            }
          } else if (child._template.node is xml.XmlText) {
            _text.add(child._template.node.text);
          } else if (child.name?.prefix == null) {
            _children.add(child);
          }
        }
      }
    }
  }

  void clear() {
    _rawChildren = null;
    _children = null;
  }

  NodeData _cloneAsChild(NodeData father) {
    var child = NodeData(_template, father.status.child(null), control);
    child._attributes = _attributes;
    child._children = _children?.map<NodeData>((e) {
      return e._cloneAsChild(child);
    })?.toList();
    return child;
  }

  NodeData clone(Map<String, dynamic> ext) {
    Status newStatus = status.child(ext);
    NodeData one = NodeData(_template, newStatus, control);
    one._attributes = _attributes;
    one._children = _children?.map<NodeData>((element) {
      return element._cloneAsChild(one);
    })?.toList();
    return one;
  }

  NodeData _firstChild(List<NodeData> nodes, [bool Function(NodeData) tester]) {
    if (nodes != null) {
      for (var node in nodes) {
        if (tester == null || tester(node)) {
          return node;
        }
      }
    }
    return null;
  }

  List<T> _convertListTo<T>(List<NodeData> nodes) {
    List<T> res = [];
    void addResult(NodeData node) {
      dynamic obj = node.t<T>();
      if (obj != null) res.add(obj);
    }

    for (var node in nodes) {
      addResult(node);
    }
    return res;
  }

  NodeData operator [](String name) {
    _processNode();
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
      xml.XmlElement element = _template.node as xml.XmlElement;
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
          element.start, element.end, status.get(element.value).toString());
    });
    return text;
  }

  String _raw;
  String get raw {
    if (_raw == null) {
      if (isElement) {
        _processNode();
        _raw = _text.join("\n");
      } else if (isAttribute) {
        _raw = (_template.node as xml.XmlAttribute).value;
      } else if (_template.node is xml.XmlText) {
        _raw = (_template.node as xml.XmlText).text;
      } else _raw = "";
    }
    return _raw;
  }
  String get text => _processText(raw);
  int get integer => int.tryParse(text);
  double get real => double.tryParse(text);
  bool get boolean {
    dynamic res = status.execute(raw);
    if (res is String) return res == "true";
    else if (res is bool) return res;
    return res != null;
  }

  bool get isAttribute => _template.node is xml.XmlAttribute;
  bool get isElement => _template.node is xml.XmlElement;
  xml.XmlName get name => _template.name;

  T child<T>() {
    if (rawChildren != null) {
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
    _processNode();

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

  T t<T>() {
    if (!isElement) {
      dynamic obj = status.execute(raw);
      if (obj is T) return obj;
      if (T == String) return obj.toString() as T;
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
  T attribute<T>(String name, [T defaultValue]) => s<T>(name, defaultValue);

  T v<T>(String txt, [T def]) {
    _ItemInfo info = XmlLayout._constructors[T];
    return info.constructor(NodeData(Template(xml.XmlText(txt), _template), _status, control), null) ?? def;
  }
  T value<T>(String value, [T defaultValue]) => v<T>(value, defaultValue);

  MethodNode _arguments;
  bool _argvInit = false;
  static const String MethodPattern = r"^{0}\(([^\)]*)\)$";
  MethodNode splitMethod(String name, int count) {
    var argv = arguments;
    if (argv != null && argv.name == name && argv.length == count) {
      return argv;
    }
    return null;
  }

  MethodNode get arguments {
    if (!isElement) {
      if (!_argvInit) {
        _arguments = MethodNode.parse(text, status);
        _argvInit = true;
      }
    }
    return _arguments;
  }

}
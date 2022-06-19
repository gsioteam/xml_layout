
part of xml_layout;

typedef ItemConstructor = dynamic Function(NodeData node, Key? key);

mixin NodeControl {
  Map<String, GlobalKey> keys = Map();

  GlobalKey _getKey(String id) {
    if (keys.containsKey(id)) return keys[id]!;
    return keys[id] = GlobalKey();
  }

  GlobalKey? find(String id) {
    return keys[id];
  }

  ItemConstructor? onUnkown;
}

class NodeData {
  Template _template;
  Status _status;
  NodeControl control;

  Map<String, List<NodeData>>? _attributes;
  List<NodeData>? _children;
  List<String>? _text;

  Status get status => _status;
  BuildContext get context => status.context;

  xml.XmlNode get xmlNode => _template.node;

  NodeData(this._template, this._status, this.control);

  void _setNode(String name, NodeData node) {
    name = name.toLowerCase();
    List<NodeData>? list = _attributes![name];
    if (list == null) {
      list = [];
      _attributes![name] = list;
    }
    list.add(node);
  }

  List<NodeData>? _rawChildren;
  List<NodeData> get rawChildren {
    if (_rawChildren == null) {
      _rawChildren = [];
      if (_template.node is xml.XmlElement) {
        FlowMessage message = FlowMessage();
        for (var childTemplate in _template.children) {
          try {
            _rawChildren!.addAll(childTemplate.generate(status, control, message));
          } catch (e) {
            print("Parse xml failed\n$e\n${_template.node}");
          }
        }
      }
    }
    return _rawChildren!;
  }

  void _processNode() {
    if (_children == null) {
      _attributes = {};
      _children = [];
      _text = [];
      if (_template.node is xml.XmlElement) {
        for (var attr in _template.attributes) {
          _setNode(attr.name.toString(), NodeData(attr, _status, control));
        }

        for (var child in rawChildren) {
          if (child.name?.prefix == "attr") {
            for (var sub in child.rawChildren) {
              _setNode(child.name!.local, sub);
            }
          } else if (child.name?.prefix == "arg") {
            for (var sub in child.rawChildren) {
              _setNode(child.name.toString(), sub);
            }
          } else if (child._template.node is xml.XmlText) {
            _text!.add(child._template.node.text);
          } else if (child.name?.prefix == null) {
            _children!.add(child);
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
    var one = NodeData(_template, father.status, control);
    one._rawChildren = _rawChildren?.map<NodeData>((element) {
      return element._cloneAsChild(one);
    }).toList();
    return one;
  }

  NodeData clone(Map<String, dynamic> ext) {
    Status newStatus = status.child(ext);
    NodeData one = NodeData(_template, newStatus, control);
    one._rawChildren = _rawChildren?.map<NodeData>((element) {
      return element._cloneAsChild(one);
    }).toList();
    return one;
  }

  NodeData? _firstChild(List<NodeData> nodes, [bool Function(NodeData)? tester]) {
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

  NodeData? operator [](String name) {
    _processNode();
    if (_attributes == null) return null;
    return _firstChild(_attributes![name.toLowerCase()]??[]);
  }

  Key? _getKey() {
    String? id = _template.node.getAttribute("id");
    if (id != null) {
      id = status.execute(id);
      if (id != null) {
        return control._getKey(id);
      }
    }
    return null;
  }

  dynamic element() {
    if (isElement) {
      xml.XmlElement element = _template.node as xml.XmlElement;
      _ItemInfo? info =
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
          Match? match =
          RegExp(r"(?<=\$)\{([^\}]+)\}").matchAsPrefix(text, off + 1);
          if (match != null) {
            ranges.add(_Range(match.start - 1, match.end, match.group(1)!));
          } else {}
        } else {
          Match? match = RegExp(r"(?<=\$)[\w_]+").matchAsPrefix(text, off + 1);
          if (match != null) {
            ranges.add(_Range(match.start - 1, match.end, match.group(0)!));
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

  String? _raw;
  String get raw {
    if (_raw == null) {
      if (isElement) {
        _processNode();
        _raw = _text!.join("\n");
      } else if (isAttribute) {
        _raw = (_template.node as xml.XmlAttribute).value;
      } else if (_template.node is xml.XmlText) {
        _raw = (_template.node as xml.XmlText).text;
      } else _raw = "";
    }
    return _raw!;
  }
  String get text => _processText(raw.trim());
  int? get integer => int.tryParse(text);
  double? get real => double.tryParse(text);
  bool get boolean {
    dynamic res = status.execute(raw);
    if (res is String) return res == "true";
    else if (res is bool) return res;
    return res != null;
  }

  bool get isAttribute => _template.node is xml.XmlAttribute;
  bool get isElement => _template.node is xml.XmlElement && _template.name!.prefix == null;
  xml.XmlName? get name => _template.name;

  T? child<T>() {
    _processNode();
    T? res;
    String text;
    if (_children!.isEmpty && (text = this.text).isNotEmpty) {
      res = v<T>(text);
    } else {
      _firstChild(_children!, (node) {
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

  List<T> children<T>() {
    _processNode();

    return _children == null ? [] : _convertListTo<T>(_children!);
  }

  Iterable<T> iterable<T>() sync* {
    FlowMessage message = FlowMessage();
    for (var child in _template.children) {
      try {
        var nodes = child.generate(status, control, message);
        for (var node in nodes) {
          var elem = node.element();
          if (elem is T && elem != null)
            yield elem;
        }
      } catch (e) {
        print("Parse xml failed\n$e\n${_template.node}");
      }
    }
  }

  List<T>? array<T>(String name) {
    _processNode();
    List<NodeData>? attrs = _attributes![name.toLowerCase()];
    var attr = attrs?.first;
    if (attr == null) return null;
    else if (attr.isElement) {
      return _convertListTo<T>(attrs!);
    } else {
      return attr.t<List<T>>();
    }
  }

  T? t<T>() {
    if (!isElement) {
      dynamic obj = status.execute(raw);
      if (obj is T) return obj;
      if (T == String) return obj.toString() as T;
      if (obj != null) {
        if ((T == int || T == double) && obj is num) {
          if (T == int) {
            return obj.toInt() as T;
          } else {
            return obj.toDouble() as T;
          }
        } else {
          print("Warring: Result $obj is not target Type $T.");
        }
      }
    }
    switch (T) {
      case String:
        {
          return text as T?;
        }
      case bool:
        {
          return boolean as T?;
        }
      case int:
        {
          return integer as T?;
        }
      case double:
        {
          return real as T?;
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
          _ItemInfo? info = XmlLayout._constructors[T];
          if (info == null) {
            return control.onUnkown?.call(this, _getKey());
          } else {
            dynamic obj = info.constructor(this, _getKey());
            return obj;
          }
        }
    }
  }
  T? convert<T>() => t<T>();

  T? s<T>(String name, [T? def]) => this[name]?.t<T>() ?? def;
  T? attribute<T>(String name, [T? defaultValue]) => s<T>(name, defaultValue);

  String? rawAttribute(String name) => _template.node.getAttribute(name);

  T? v<T>(String txt, [T? def]) {
    _ItemInfo? info = XmlLayout._constructors[T];
    return info?.constructor(NodeData(Template(xml.XmlText(txt), _template), _status, control), null) ?? def;
  }
  T? value<T>(String value, [T? defaultValue]) => v<T>(value, defaultValue);

  MethodNode? _arguments;
  bool _argvInit = false;
  static const String MethodPattern = r"^{0}\(([^\)]*)\)$";
  MethodNode? splitMethod(String name, int count) {
    var argv = arguments;
    if (argv != null && argv.name == name && argv.length == count) {
      return argv;
    }
    return null;
  }

  MethodNode? get arguments {
    if (!isElement) {
      if (!_argvInit) {
        _arguments = MethodNode.parse(text, status);
        _argvInit = true;
      }
    }
    return _arguments;
  }

}
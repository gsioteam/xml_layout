
import 'dart:async';

import 'package:xml/xml.dart' as xml;

import 'status.dart';
import 'xml_layout.dart';

typedef TemplateConstructor<T extends Template> = T Function(xml.XmlNode node, Template? parent);

Map<String, TemplateConstructor> _flowConstructors = {
  "for": (node, parent) => ForFlowTemplate(node as xml.XmlElement, parent),
  "if": (node, parent) => IfFlowTemplate(node as xml.XmlElement, parent),
  "else": (node, parent) => ElseFlowTemplate(node as xml.XmlElement, parent),
};

void registerFlowTemplate<T extends Template>(String tagName, TemplateConstructor<T> constructor) {
  _flowConstructors[tagName.toLowerCase()] = constructor;
}

class _InnerMessage {
  late String type;
  dynamic data;
}

class FlowMessage {
  _InnerMessage? _inner;

  void clear() {
    _inner = null;
  }

  void set(String type, dynamic data) {
    _inner = _InnerMessage()
      ..type = type
      ..data = data;
  }

  dynamic get data => _inner?.data;
}

abstract class Template {
  xml.XmlNode node;
  Template? parent;

  List<Template>? _children;
  List<Template> get children {
    if (_children == null) {
      _children = [];
      if (node is xml.XmlElement) {
        for (var child in node.children) {
          if (child is xml.XmlElement) {
            _children!.add(Template(child, this));
          } else if (child is xml.XmlText) {
            if (child.text.trim().isNotEmpty)
              _children!.add(Template(child, this));
          }
        }
      }
    }
    return _children!;
  }

  List<Template>? _attributes;
  List<Template> get attributes {
    if (_attributes == null) {
      _attributes = [];
      if (node is xml.XmlElement) {
        for (var attr in node.attributes) {
          _attributes!.add(Template(attr, this));
        }
      }
    }
    return _attributes!;
  }

  xml.XmlName? get name {
    if (node is xml.XmlElement) {
      return (node as xml.XmlElement).name;
    } else if (node is xml.XmlAttribute) {
      return (node as xml.XmlAttribute).name;
    } else {
      return null;
    }
  }

  String? get messageFilter => null;

  Template.init(this.node, this.parent);
  Iterable<NodeData> generate(Status status, NodeControl control, [FlowMessage? message]) {
    if (message == null) message = FlowMessage();
    if (message._inner?.type != messageFilter) {
      message.clear();
    }
    return processChildren(status, control, message);
  }

  Iterable<NodeData> processChildren(Status status, NodeControl control, FlowMessage message);

  factory Template(xml.XmlNode node, [Template? parent]) {
    if (node is xml.XmlElement) {
      String tagName = node.name.toString().toLowerCase();
      if (_flowConstructors.containsKey(tagName)) {
        var constructor = _flowConstructors[tagName];
        return constructor!(node, parent);
      } else {
        return ElementTemplate(node, parent);
      }
    } else if (node is xml.XmlText) {
      return TextTemplate(node, parent);
    } else if (node is xml.XmlAttribute) {
      return AttributeTemplate(node, parent);
    }
    throw Exception(["Unkown node type"]);
  }

}

class ElementTemplate extends Template {
  ElementTemplate(xml.XmlElement node, [Template? parent]) : super.init(node, parent);

  Status? _oldStatus;
  NodeData? _cachedNode;

  @override
  Iterable<NodeData> processChildren(Status status, NodeControl control, FlowMessage message) {
    if (_oldStatus != status) {
      _cachedNode = null;
      _oldStatus = status;
    }
    if (_cachedNode == null)
      _cachedNode = NodeData(this, status, control);
    else
      _cachedNode!.clear();
    return [_cachedNode!];
  }
}

class TextTemplate extends Template {
  TextTemplate(xml.XmlText node, [Template? parent]) : super.init(node, parent);

  Status? _oldStatus;
  NodeData? _cachedNode;

  @override
  Iterable<NodeData> processChildren(Status status, NodeControl control, FlowMessage message) {
    if (_oldStatus != status) {
      _cachedNode = null;
      _oldStatus = status;
    }
    if (_cachedNode == null)
      _cachedNode = NodeData(this, status, control);
    else
      _cachedNode!.clear();
    return [_cachedNode!];
  }
}

class AttributeTemplate extends Template {
  AttributeTemplate(xml.XmlAttribute node, [Template? parent]) : super.init(node, parent);

  Status? _oldStatus;
  NodeData? _cachedNode;

  @override
  Iterable<NodeData> processChildren(Status status, NodeControl control, FlowMessage message) {
    if (_oldStatus != status) {
      _cachedNode = null;
      _oldStatus = status;
    }
    if (_cachedNode == null)
      _cachedNode = NodeData(this, status, control);
    else
      _cachedNode!.clear();
    return [_cachedNode!];
  }
}

class ForFlowTemplate extends Template {
  ForFlowTemplate(xml.XmlElement node, [Template? parent]) : super.init(node, parent);

  bool _testArray(List? list1, List? list2) {
    if (list1 != null && list2 != null && list1.length == list2.length) {
      int n = list1.length;
      for (int i = 0; i < n; ++i) {
        if (list1[i] != list2[i]) return false;
      }
    }
    return false;
  }

  @override
  Iterable<NodeData> processChildren(Status status, NodeControl control, FlowMessage message) sync* {
    xml.XmlElement element = node as xml.XmlElement;
    String item = element.getAttribute("item") ?? "item";
    String index = element.getAttribute("index") ?? "index";

    List? arr;
    xml.XmlAttribute? fnode = element.getAttributeNode("array");
    if (fnode != null) {
      arr = status.execute(fnode.value) as List?;
    }
    if (arr == null) {
      fnode = element.getAttributeNode("count");
      arr = [];
      if (fnode != null) {
        var num = status.execute(fnode.value);
        if (num is int) {
          for (int i = 0; i < num; ++i) {
            arr.add(i);
          }
        }
      }
    }

    if (arr.length > 0) {
      for (int i = 0, t = arr.length; i < t; ++i) {
        Status newStatus = status.child({
          item: arr[i],
          index: i
        });
        FlowMessage message = FlowMessage();
        for (var child in children) {
          yield* child.generate(newStatus, control, message);
        }
      }
    }
  }
}

const String _ifFlowType = "if";

class IfFlowTemplate extends Template {
  IfFlowTemplate(xml.XmlElement node, [Template? parent]) : super.init(node, parent);

  @override
  Iterable<NodeData> processChildren(Status status, NodeControl control, FlowMessage message) sync* {
    xml.XmlElement element = node as xml.XmlElement;
    xml.XmlAttribute? fnode = element.getAttributeNode("candidate");
    bool candidate = false;
    if (fnode != null) {
      var res = status.execute(fnode.value);
      if (res is String) candidate = res == "true";
      else if (res is bool) candidate = res;
    }

    if (candidate) {
      FlowMessage message = FlowMessage();
      for (var child in children) {
        yield* child.generate(status, control, message);
      }
    }
    message.set(_ifFlowType, candidate);
  }
}

class ElseFlowTemplate extends Template {
  ElseFlowTemplate(xml.XmlElement node, [Template? parent]) : super.init(node, parent);

  @override
  String get messageFilter => _ifFlowType;

  @override
  Iterable<NodeData> processChildren(Status status, NodeControl control, FlowMessage message) sync* {
    bool candidate = true, checkCandi = message.data == false;
    if (checkCandi) {
      xml.XmlElement element = node as xml.XmlElement;
      xml.XmlAttribute? fnode = element.getAttributeNode("candidate");
      candidate = true;
      if (fnode != null) {
        var res = status.execute(fnode.value);
        if (res is String) candidate = res == "true";
        else if (res is bool) candidate = res;
      }

      if (candidate) {
        FlowMessage message = FlowMessage();
        for (var child in children) {
          yield* child.generate(status, control, message);
        }
      }
    }
    message.set(_ifFlowType, candidate || !checkCandi);
  }
}

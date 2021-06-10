import 'package:flutter/material.dart';
import 'package:xml_layout/status.dart';
import '../template.dart';
import '../xml_layout.dart';

import '../register.dart';
import 'package:xml/xml.dart' as xml;

class ArgsCountError extends Error {}

abstract class Action {
  String ret;
  List<Argument> args;

  Action({this.ret, this.args});
  dynamic call(NodeData node);
}

class Call extends Action {
  Function func;

  Call({this.func, String ret, List<Argument> args})
      : super(ret: ret, args: args);

  dynamic call(NodeData node) {
    if (func != null) {
      return Function.apply(func, args?.map((e) => e.value)?.toList() ?? []);
    }
  }
}

class Builder extends Action {
  final NodeData node;

  Builder(this.node, {
    String ret
  }) : super(ret: ret);

  @override
  call(NodeData node) {
    return this.node.child();
  }
}

class SetArgument extends Action {
  final dynamic argument;
  SetArgument({String ret, this.argument}) : super(ret: ret);

  @override
  call(NodeData node) {
    return argument;
  }
}

class Argument {
  final NodeData node;
  Argument(this.node);

  dynamic get value => node.s("value");
}

typedef _Func<T> = T Function([dynamic, dynamic, dynamic, dynamic, dynamic]);
class _ReturnType<T> {
  _Func<T> Function(NodeData node, Key key) function;
}
Map<String, _ReturnType> _returnTypes = {};

void registerReturnType<T>() {
  String typeName = T.toString().toLowerCase();
  _returnTypes[typeName] = _ReturnType<T>()
    ..function = (node, key) {
      return ([a1, a2, a3, a4, a5]) {
        Map<String, dynamic> data = {
          "args": [a1, a2, a3, a4, a5]
        };
        node.status.data = data;
        var children = node.children<Action>();
        dynamic ret;
        children.forEach((element) {
          ret = element.call(node);
          if (element.ret != null) data[element.ret] = ret;
        });

        return ret as T;
      };
    };
}

_ReturnType<Null> _defaultReturnType = _ReturnType<Null>()
  ..function = (node, key) {
  return ([a1, a2, a3, a4, a5]) {
    Map<String, dynamic> data = {
      "args": [a1, a2, a3, a4, a5]
    };
    node.status.data = data;
    var children = node.children<Action>();
    dynamic ret;
    children.forEach((element) {
      ret = element.call(node);
      if (element.ret != null) data[element.ret] = ret;
    });
  };
};

class FunctionTemplate extends Template {
  FunctionTemplate(xml.XmlElement node, [Template parent]) : super.init(node, parent);

  NodeData _cachedNode;

  @override
  List<NodeData> processChildren(Status status, NodeControl control, FlowMessage message) {
    if (_cachedNode == null) {
      _cachedNode = NodeData(this, status.child({}), control);
    }
    return [_cachedNode];
  }
}

Register register = Register(() {
  registerFlowTemplate<FunctionTemplate>("Function", (node, parent) => FunctionTemplate(node, parent));
  XmlLayout.register("Function", (node, key) {
    String type = node.s<String>("returnType")?.toLowerCase();
    _ReturnType returnType = _returnTypes.containsKey(type) ? _returnTypes[type] : _defaultReturnType;

    return returnType.function(node, key);
  });
  XmlLayout.register("Call", (node, key) {
    return Call(
        func: node.s<Function>("function"),
        ret: node.s<String>("return"),
        args: node.children<Argument>());
  });
  XmlLayout.register("Builder", (node, key) {
    return Builder(
      node,
    );
  });
  XmlLayout.register("SetArgument", (node, key) {
    return SetArgument(
      ret: node.s<String>("return"),
      argument: node.s("argument")
    );
  });

  XmlLayout.register("Argument", (node, key) {
    return Argument(node);
  });

});

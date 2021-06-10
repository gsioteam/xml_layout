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

  bool _loaded = false;
  dynamic _result;
  dynamic get result {
    if (!_loaded) {
      _result = call();
      _loaded = true;
    }
    return _result;
  }

  void execute(Status status) {
    if (ret != null) {
      if (status.data == null) {
        status.data = {};
      }
      status.data[ret] = result;
    }
  }
  dynamic call();
}

class Call extends Action {
  Function func;

  Call({this.func, String ret, List<Argument> args})
      : super(ret: ret, args: args);

  dynamic call() {
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
  call() {
    return this.node.child();
  }
}

class SetArgument extends Action {
  final dynamic argument;
  SetArgument({String ret, this.argument}) : super(ret: ret);

  @override
  call() {
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
  _Func<T> function(NodeData node) {
    return ([a1, a2, a3, a4, a5]) {
      Map<String, dynamic> data = {
        "args": [a1, a2, a3, a4, a5]
      };
      node.status.data = data;
      dynamic ret = creator(node);

      return ret as T;
    };
  }
  T creator(NodeData node) {
    var data = node.status.data;
    var children = node.children<Action>();
    dynamic ret;
    children.forEach((element) {
      ret = element.result;
    });

    return ret as T;
  }
}
Map<String, _ReturnType> _returnTypes = {};

void registerReturnType<T>() {
  String typeName = T.toString().toLowerCase();
  _returnTypes[typeName] = _ReturnType<T>();
}

_ReturnType<Null> _defaultReturnType = _ReturnType<Null>();

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

    if (node.s<bool>("creator") == true) {
      return returnType.creator(node);
    } else
      return returnType.function(node);
  });
  XmlLayout.register("Call", (node, key) {
    var call = Call(
        func: node.s<Function>("function"),
        ret: node.s<String>("return"),
        args: node.children<Argument>());
    call.execute(node.status);
    return call;
  });
  XmlLayout.register("Builder", (node, key) {
    var builder = Builder(
      node,
    );
    builder.execute(node.status);
    return builder;
  });
  XmlLayout.register("SetArgument", (node, key) {
    var set = SetArgument(
        ret: node.s<String>("return"),
        argument: node.s("argument")
    );
    set.execute(node.status);
    return set;
  });

  XmlLayout.register("Argument", (node, key) {
    return Argument(node);
  });

});

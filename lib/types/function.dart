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
  Status _status;

  Action({this.ret, this.args});

  bool _loaded = false;
  dynamic _result;
  dynamic get result {
    if (!_loaded) {
      _result = call(_status);
      _loaded = true;
    }
    return _result;
  }

  void execute(Status status) {
    _status = status;
    if (status.tag == _functionTag) {
      if (!_loaded) {
        _result = call(_status);
        _loaded = true;
      }
      if (ret != null) {
        if (status.data == null) {
          status.data = {};
        }
        status.data[ret] = _result;
      }
    }
  }
  dynamic call(Status status);
}

class Call extends Action {
  Function func;

  Call({this.func, String ret, List<Argument> args})
      : super(ret: ret, args: args);

  dynamic call(Status status) {
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
  call(Status status) {
    return this.node.child();
  }
}

class SetArgument extends Action {
  final dynamic argument;
  SetArgument({String ret, this.argument}) : super(ret: ret);

  @override
  call(Status status) {
    return argument;
  }
}

class Script extends Action {
  final String raw;
  Script(this.raw);

  @override
  call(Status status) {
    dynamic ret;
    if (status != null) {
      var lines = raw.split('\n');
      for (var line in lines) {
        String script = line.trim();
        if (script.isNotEmpty) {
          ret = status.execute(script);
        }
      }
    }
    return ret;
  }

}

class Argument {
  final NodeData node;
  Argument(this.node);

  dynamic get value => node.s("value");
}

const List _emptyArgs = [null, null, null, null, null];
typedef _Func<T> = T Function([dynamic, dynamic, dynamic, dynamic, dynamic]);
class _ReturnType<T> {
  _Func<T> function(NodeData node) {
    return ([a1, a2, a3, a4, a5]) {
      return creator(_createNewNode(node, {
        "args": [a1, a2, a3, a4, a5]
      }));
    };
  }
  T creator(NodeData node) {
    var children = node.children();
    dynamic ret;
    children.forEach((element) {
      if (element is Action) {
        ret = element.result;
      } else {
        ret = element;
      }
    });

    if (T != Null) {
      return ret as T;
    } else {
      return null;
    }
  }
}
Map<String, _ReturnType> _returnTypes = {};

void registerReturnType<T>() {
  String typeName = T.toString().toLowerCase();
  _returnTypes[typeName] = _ReturnType<T>();
}
int _functionTag = 0x10003;

_ReturnType<Null> _defaultReturnType = _ReturnType<Null>();

NodeData _createNewNode(NodeData node, Map<String, dynamic> data) {
  var ret = node.clone(data);
  ret.status.tag = _functionTag;
  return ret;
}

Register register = Register(() {
  XmlLayout.register("Function", (node, key) {
    String type = node.s<String>("returnType")?.toLowerCase();
    _ReturnType returnType = _returnTypes.containsKey(type) ? _returnTypes[type] : _defaultReturnType;

    if (node.s<bool>("creator") == true) {
      return returnType.creator(_createNewNode(node, {
        "args": _emptyArgs
      }));
    } else {
      return returnType.function(node);
    }
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
  XmlLayout.register("Script", (node, key) {
    var script = Script(node.raw);
    script.execute(node.status);
    return script;
  });
  XmlLayout.register("Argument", (node, key) {
    return Argument(node);
  });

});

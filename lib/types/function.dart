import 'package:xml_layout/xml_layout.dart';

import '../register.dart';

class ArgsCountError extends Error {}

abstract class Action {
  String ret;
  List<Argument> args;

  Action({this.ret, this.args});
  dynamic call(NodeData node);
}

class Call extends Action {
  dynamic Function(List) func;

  Call({this.func, String ret, List<Argument> args})
      : super(ret: ret, args: args);

  dynamic call(NodeData node) {
    return func?.call(args?.map((e) => e.value)?.toList() ?? []);
  }
}

class Apply extends Action {
  String name;

  Apply({this.name, String ret, List<Argument> args})
      : super(ret: ret, args: args);

  dynamic call(NodeData node) {
    return node.apply(name, args?.map((e) => e.value)?.toList() ?? []);
  }
}

class Argument {
  dynamic value;
  Argument(this.value);
}

Register reg = Register(() {
  XmlLayout.reg("Function", (node, key) {
    return ([a1, a2, a3, a4, a5]) {
      Map<String, dynamic> data = {
        "args": [a1, a2, a3, a4, a5]
      };
      NodeData newNode = node.clone(data);
      var children = newNode.children<Action>();
      dynamic ret;
      children.forEach((element) {
        ret = element.call(node);
        if (element.ret != null) data[element.ret] = ret;
      });
      return ret;
    };
  });

  XmlLayout.reg(Call, (node, key) {
    return Call(
        func: node.s<void Function(List)>("function"),
        ret: node.s<String>("return"),
        args: node.children<Argument>());
  });

  XmlLayout.reg(Apply, (node, key) {
    return Apply(
        name: node.s<String>("name"),
        ret: node.s<String>("return"),
        args: node.children<Argument>());
  });

  XmlLayout.reg(Argument, (node, key) => Argument(node.s("value")));
});

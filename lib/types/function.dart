import 'package:xml_layout/xml_layout.dart';

import '../register.dart';

class ArgsCountError extends Error {}

class Call {
  dynamic Function(List) func;
  String ret;
  List<Argument> args;

  Call({this.func, this.ret, this.args});

  dynamic call() {
    return func?.call(args?.map((e) => e.value)?.toList() ?? []);
  }
}

class Argument {
  dynamic value;
  Argument(this.value);
}

Register reg = Register(() {
  XmlLayout.reg("Function", (node, key) {
    int count = node.s<int>("argsCount", 0);
    if (count < 0 || count > 5) {
      throw ArgsCountError();
    }
    return ([a1, a2, a3, a4, a5]) {
      Map<String, dynamic> data = {
        "args": [a1, a2, a3, a4, a5]
      };
      NodeData newNode = node.clone(data);
      var children = newNode.children();
      dynamic ret;
      children.forEach((element) {
        if (element is Call) {
          ret = element.call();
          if (element.ret != null) data[element.ret] = ret;
        }
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

  XmlLayout.reg(Argument, (node, key) => Argument(node.s("value")));
});

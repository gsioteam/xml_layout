import '../xml_layout.dart';
import 'function.dart' as function;
import '../register.dart';

Register reg = Register(() {
  function.reg();

  XmlLayout.reg("builder", (node, key) {
    var builder = node.s<dynamic Function(List)>("builder");
    if (builder != null) {
      var args = node.children<function.Argument>();
      return builder(args?.map((e) => e.value)?.toList());
    }
    return null;
  });
  XmlLayout.reg("proxy", (node, key) {
    return node.s("target");
  });
});

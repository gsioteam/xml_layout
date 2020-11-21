import '../xml_layout.dart';
import 'function.dart' as function;
import '../register.dart';

Register register = Register(() {

  XmlLayout.register("builder", (node, key) {
    var builder = node.s<dynamic Function(List)>("builder");
    if (builder != null) {
      var args = node.children<function.Argument>();
      return builder(args?.map((e) => e.value)?.toList());
    }
    return null;
  });
  XmlLayout.register("proxy", (node, key) {
    return node.s("target");
  });
});

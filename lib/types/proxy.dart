import '../xml_layout.dart';
import 'function.dart' as function;
import '../register.dart';

Register register = Register(() {
  XmlLayout.register("proxy", (node, key) {
    return node.s("target");
  });
});

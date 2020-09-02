import 'package:flutter/gestures.dart';

import '../register.dart';
import '../xml_layout.dart';

Register reg = Register(() {
  XmlLayout.regEnum(DragStartBehavior.values);
});

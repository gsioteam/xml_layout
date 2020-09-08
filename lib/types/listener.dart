
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../register.dart';
import '../xml_layout.dart';

Register reg = Register(() {
  XmlLayout.reg(Listener, (node, key) {
    return Listener(
      key: key,
      onPointerUp: node.s<PointerUpEventListener>("onPointerUp"),
      onPointerDown: node.s<PointerDownEventListener>("onPointerDown"),
      onPointerMove: node.s<PointerMoveEventListener>("onPointerMove"),
      onPointerCancel: node.s<PointerCancelEventListener>("onPointerCancel"),
      onPointerSignal: node.s<PointerSignalEventListener>("onPointerSignal"),
      behavior: node.s<HitTestBehavior>("behavior"),
      child: node.child<Widget>(),
    );
  });

  XmlLayout.regEnum(HitTestBehavior.values);
});
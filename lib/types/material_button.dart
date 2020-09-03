import 'package:flutter/material.dart';

import '../xml_layout.dart';

import '../register.dart';

Register reg = Register(() {
  XmlLayout.reg(MaterialButton, (node, key) {
    return MaterialButton(
        key: key,
        onPressed: node.s<VoidCallback>("onPressed"),
        onLongPress: node.s<VoidCallback>("onLongPress"),
        onHighlightChanged: node.s<ValueChanged<bool>>("onHighlightChanged"),
        textTheme: node.s<ButtonTextTheme>("textTheme"),
        textColor: node.s<Color>("textColor"),
        disabledTextColor: node.s<Color>("disabledTextColor"),
        color: node.s<Color>("color"),
        disabledColor: node.s<Color>("disabledColor"),
        focusColor: node.s<Color>("focusColor"),
        hoverColor: node.s<Color>("hoverColor"),
        highlightColor: node.s<Color>("highlightColor"),
        splashColor: node.s<Color>("splashColor"),
        colorBrightness: node.s<Brightness>("colorBrightness"),
        elevation: node.s<double>("elevation"),
        focusElevation: node.s<double>("focusElevation"),
        hoverElevation: node.s<double>("hoverElevation"),
        highlightElevation: node.s<double>("highlightElevation"),
        disabledElevation: node.s<double>("disabledElevation"),
        padding: node.s<EdgeInsetsGeometry>("padding"),
        visualDensity: node.s<VisualDensity>("visualDensity"),
        shape: node.s<ShapeBorder>("shape"),
        clipBehavior: node.s<Clip>("clipBehavior", Clip.none),
        focusNode: node.s<FocusNode>("focusNode"),
        autofocus: node.s<bool>("autofocus", false),
        materialTapTargetSize:
            node.s<MaterialTapTargetSize>("materialTapTargetSize"),
        minWidth: node.s<double>("minWidth"),
        height: node.s<double>("height"),
        enableFeedback: node.s<bool>("enableFeedback", false),
        child: node.child<Widget>());
  });
  XmlLayout.reg(VisualDensity, (node, key) {
    switch (node.text) {
      case "standard":
        return VisualDensity.standard;
      case "comfortable":
        return VisualDensity.comfortable;
      case "compact":
        return VisualDensity.compact;
      case "adaptivePlatformDensity":
        return VisualDensity.adaptivePlatformDensity;
      default:
        return null;
    }
  }, mode: XmlLayout.Text);
  XmlLayout.regEnum(MaterialTapTargetSize.values);
});

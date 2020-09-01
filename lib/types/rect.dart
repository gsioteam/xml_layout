

import 'package:flutter/material.dart';

import '../parser.dart';
import '../xml_layout.dart';
import '../register.dart';

Register reg = Register(() {
  XmlLayout.reg(Rect, (node, key) {
    switch (node.text) {
      case 'zero':
        return Rect.zero;
      case 'largest':
        return Rect.largest;
      default:
        {
          MethodNode a;
          if ((a = node.splitMethod("fromLTRB", 4)) != null) {
            return Rect.fromLTRB(double.tryParse(a[0]), double.tryParse(a[1]),
                double.tryParse(a[2]), double.tryParse(a[3]));
          } else if ((a = node.splitMethod("fromLTWH", 4)) != null) {
            return Rect.fromLTWH(double.tryParse(a[0]), double.tryParse(a[1]),
                double.tryParse(a[2]), double.tryParse(a[3]));
          } else if ((a = node.splitMethod("fromCircle", 2)) != null) {
            return Rect.fromCircle(
                center: node.v<Offset>(a[0]), radius: double.tryParse(a[1]));
          } else if ((a = node.splitMethod("fromCenter", 3)) != null) {
            return Rect.fromCenter(
                center: node.v<Offset>(a[0]),
                width: double.tryParse(a[1]),
                height: double.tryParse(a[2]));
          } else if ((a = node.splitMethod("fromPoints", 2)) != null) {
            return Rect.fromPoints(node.v<Offset>(a[0]), node.v<Offset>(a[1]));
          } else
            return null;
        }
    }
  }, mode: XmlLayout.Text);
  XmlLayout.reg(RelativeRect, (node, key) {
    switch (node.text) {
      case 'fill':
        return RelativeRect.fill;
      default:
        {
          MethodNode a;
          if ((a = node.splitMethod("fromLTRB", 4)) != null) {
            return RelativeRect.fromLTRB(
              double.tryParse(a[0]),
              double.tryParse(a[1]),
              double.tryParse(a[2]),
              double.tryParse(a[3]),
            );
          } else if ((a = node.splitMethod("fromSize", 2)) != null) {
            return RelativeRect.fromSize(
                node.v<Rect>(a[0]), node.v<Size>(a[1]));
          } else if ((a = node.splitMethod("fromRect", 2)) != null) {
            return RelativeRect.fromRect(
                node.v<Rect>(a[0]), node.v<Rect>(a[1]));
          } else
            return null;
        }
    }
  }, mode: XmlLayout.Text);
  XmlLayout.reg(Size, (node, key) {
    switch (node.text) {
      case 'zero':
        return Size.zero;
      case 'infinite':
        return Size.infinite;
      default:
        {
          MethodNode a;
          if ((a = node.splitMethod("", 2)) != null) {
            return Size(double.parse(a[0]), double.parse(a[1]));
          } else if ((a = node.splitMethod("square", 1)) != null) {
            return Size.square(double.parse(a[0]));
          } else if ((a = node.splitMethod("fromWidth", 1)) != null) {
            return Size.fromWidth(double.parse(a[0]));
          } else if ((a = node.splitMethod("fromHeight", 1)) != null) {
            return Size.fromHeight(double.parse(a[0]));
          } else if ((a = node.splitMethod("fromRadius", 1)) != null) {
            return Size.fromRadius(double.parse(a[0]));
          }
          return null;
        }
    }
  }, mode: XmlLayout.Text);
});
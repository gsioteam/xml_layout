
import 'dart:html';

import 'package:flutter/cupertino.dart';

import 'exceptions.dart';
import 'xml_layout.dart';
import 'types/colors.dart';
import 'types/text.dart' as text;
import 'types/paint.dart' as paint;

double _parseDouble(String v) {
  v = v.trim();
  if (v.length > 0) {
    try {
      return double.parse(v);
    } catch (e) {

    }
  }
  return null;
}

void initTypes() {
  XMLLayout.reg(AlignmentGeometry, (node, _) {
    String text = node.text;
    switch (text) {
      case "topLeft": return Alignment.topLeft;
      case "topCenter": return Alignment.topCenter;
      case "topRight": return Alignment.topRight;
      case "centerLeft": return Alignment.centerLeft;
      case "center": return Alignment.center;
      case "centerRight": return Alignment.centerRight;
      case "bottomLeft": return Alignment.bottomLeft;
      case "bottomCenter": return Alignment.bottomCenter;
      case "bottomRight": return Alignment.bottomRight;
      case "topStart": return AlignmentDirectional.topStart;
      case "topEnd": return AlignmentDirectional.topEnd;
      case "centerStart": return AlignmentDirectional.centerStart;
      case "centerEnd": return AlignmentDirectional.centerEnd;
      case "bottomStart": return AlignmentDirectional.bottomStart;
      case "bottomEnd": return AlignmentDirectional.bottomEnd;
      default: {
        List<String> arr = text.split(",");
        if (arr.length >= 2) {
          return Alignment(double.parse(arr[0]), double.parse(arr[1]));
        }
      }
    }
    return null;
  });

  XMLLayout.reg(EdgeInsetsGeometry, (node, _) {
    String text = node.text;
    var arr = text.split(",");
    if (arr.length == 1) {
      return EdgeInsets.all(double.parse(arr[0]));
    } else if (arr.length == 2) {
      double x = _parseDouble(arr[0]), y = _parseDouble(arr[1]);
      return EdgeInsets.only(
        left: x,
        right: x,
        top: y,
        bottom: y
      );
    } else if (arr.length == 4) {
      double l = _parseDouble(arr[0]), r = _parseDouble(arr[1]), t = _parseDouble(arr[2]), b = _parseDouble(arr[3]);
      return EdgeInsets.only(
          left: l,
          right: r,
          top: t,
          bottom: b
      );
    } else {
      throw InvalidateParametersException(EdgeInsetsGeometry, arr.length);
    }
  });

  registerColors();

  XMLLayout.reg(Clip, (node, _) {
    String text = node.text;
    switch (text) {
      case 'none': return Clip.none;
      case 'hardEdge': return Clip.hardEdge;
      case 'antiAlias': return Clip.antiAlias;
      case 'antiAliasWithSaveLayer': return Clip.antiAliasWithSaveLayer;
      default: {
        return Clip.none;
      }
    }
  });

  XMLLayout.reg(Container, (node, key) {
    return Container(
      key: key,
      child: node.child<Widget>(),
      alignment: node.s<AlignmentGeometry>("alignment"),
      padding: node.s<EdgeInsetsGeometry>("padding"),
      color: node.s<Color>("color"),
      decoration: node.s<Decoration>("decoration"),
      foregroundDecoration: node.s<Decoration>("foregroundDecoration"),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
      constraints: node.s<BoxConstraints>("constraints"),
      margin: node.s<EdgeInsetsGeometry>("margin"),
      clipBehavior: node.s<Clip>("clipBehavior"),
    );
  });

  text.reg();
  paint.reg();
}
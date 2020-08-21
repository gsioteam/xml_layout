
import 'dart:ui';

import '../xml_layout.dart';
import 'package:flutter/material.dart';

void reg() {

  XMLLayout.regType(Text, (node) {
    if (node.isAttribute) {
      return Text(node.text);
    }
    return null;
  });

  XMLLayout.regType(FontWeight, (node) {
    switch (node.text) {
      case "w100": return FontWeight.w100;
      case "w200": return FontWeight.w200;
      case "w300": return FontWeight.w300;
      case "w400": return FontWeight.w400;
      case "w500": return FontWeight.w500;
      case "w600": return FontWeight.w600;
      case "w700": return FontWeight.w700;
      case "w800": return FontWeight.w800;
      case "w900": return FontWeight.w900;
      case "bold": return FontWeight.bold;
      case "normal": return FontWeight.normal;
      default: return null;
    }
  });
  XMLLayout.regType(FontStyle, (node) {
    switch (node.text) {
      case 'normal': return FontStyle.normal;
      case 'italic': return FontStyle.italic;
      default: return null;
    }
  });
  XMLLayout.regType(TextBaseline, (node) {
    switch (node.text) {
      case 'alphabetic': return TextBaseline.alphabetic;
      case 'ideographic': return TextBaseline.ideographic;
      default: return null;
    }
  });
  XMLLayout.regType(Locale, (node) {
    List<String> arr = node.text?.split(",");
    if (arr != null) {
      if (arr.length >= 2) {
        return Locale(arr[0], arr[1]);
      } else if (arr.length == 1) {
        return Locale(arr[0]);
      }
    }
    return null;
  });

  XMLLayout.regType(TextStyle, (node) {
    return TextStyle(
      inherit: node.s<bool>("color"),
      color: node.s<Color>("color"),
      backgroundColor: node.s<Color>("backgroundColor"),
      fontSize: node.s<double>("fontSize"),
      fontWeight: node.s<FontWeight>("fontWeight"),
      fontStyle: node.s<FontStyle>("fontStyle"),
      letterSpacing: node.s<double>("letterSpacing"),
      wordSpacing: node.s<double>("wordSpacing"),
      textBaseline: node.s<TextBaseline>("textBaseline"),
      height: node.s<double>("height"),
      locale: node.s<Locale>("locale"),
      foreground: node.s<Paint>("foreground"),
      background: node.s<Paint>("background"),
      shadows: node.arr<Shadow>("shadows"),
    );
  });

  XMLLayout.reg(Text, (node, key) {
    return Text(
      node["text"]?.text ?? node.text,
      key: key,
      style: node.s<TextStyle>("style"),
      strutStyle: node.s<StrutStyle>("strutStyle"),
      textAlign: node.s<TextAlign>("textAlign"),
      textDirection: node.s<TextDirection>("textDirection"),
      locale: node.s<Locale>("locale"),
      softWrap: node.s<bool>("softWrap"),
      overflow: node.s<TextOverflow>("overflow"),
      textScaleFactor: node.s<double>("textScaleFactor"),
      maxLines: node.s<int>("maxLines"),
      semanticsLabel: node.s<String>("semanticsLabel"),
      textWidthBasis: node.s<TextWidthBasis>("textWidthBasis"),
      textHeightBehavior: node.s<TextHeightBehavior>("textHeightBehavior"),
    );
  });
}

import 'dart:ui';

import 'package:flutter/gestures.dart';

import '../xml_layout.dart';
import 'package:flutter/material.dart';

import '../xml_layout.dart';
import '../xml_layout.dart';
import '../xml_layout.dart';

void reg() {

  XMLLayout.reg(FontWeight, (node, key) {
    switch (node.text) {
      case 'w100': return FontWeight.w100;
      case 'w200': return FontWeight.w200;
      case 'w300': return FontWeight.w300;
      case 'w400': return FontWeight.w400;
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700;
      case 'w800': return FontWeight.w800;
      case 'w900': return FontWeight.w900;
      case 'normal': return FontWeight.normal;
      case 'bold': return FontWeight.bold;
      default: return null;
    }
  });
  XMLLayout.regEnum(FontStyle.values);
  XMLLayout.regEnum(TextBaseline.values);
  XMLLayout.reg(Locale, (node, _) {
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

  XMLLayout.reg(TextStyle, (node, _) {
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
  }, mode: XMLLayout.Element);

  XMLLayout.reg(Text, (node, key) {
    if (node.isElement) {
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
    } else {
      return Text(node.text, key: key,);
    }
  });
  XMLLayout.reg("Text.rich", (node, key) {
    return Text.rich(
      node.child<InlineSpan>(),
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
  XMLLayout.regEnum(TextWidthBasis.values);
  XMLLayout.regEnum(TextOverflow.values);
  XMLLayout.regEnum(TextDirection.values);

  XMLLayout.reg(TextHeightBehavior, (node, key) {
    List<String> params;
    if ((params = node.splitMethod("", 2)) != null) {
      return TextHeightBehavior(applyHeightToFirstAscent: params[0] == 'true', applyHeightToLastDescent: params[1] == 'true');
    } else if ((params = node.splitMethod("fromEncoded", 1)) != null) {
      return TextHeightBehavior.fromEncoded(int.parse(params[0]));
    } else return null;
  }, mode: XMLLayout.Text);

  XMLLayout.reg(TextSpan, (node, key) {
    var children = node.children<InlineSpan>();
    if (children.length == 0) children = null;
    return TextSpan(
      text: node.s<String>("text"),
      children: children,
      style: node.s<TextStyle>("style"),
      recognizer: node.s<GestureRecognizer>("recognizer"),
      semanticsLabel: node.s<String>("semanticsLabel"),
    );
  }, mode: XMLLayout.Element);

  XMLLayout.regEnum(PlaceholderAlignment.values);
  XMLLayout.reg(WidgetSpan, (node, key) {
    return WidgetSpan(
      child: node.child<Widget>(),
      alignment: node.s<PlaceholderAlignment>("alignment"),
      baseline: node.s<TextBaseline>("baseline"),
      style: node.s<TextStyle>("style")
    );
  }, mode: XMLLayout.Element);

  XMLLayout.reg(StrutStyle, (node, key) {
    return StrutStyle(
      fontFamily: node.s<String>("fontFamily"),
      fontFamilyFallback: node.s<String>("fontFamilyFallback")?.split(","),
      fontSize: node.s<double>("fontSize"),
      height: node.s<double>("height"),
      leading: node.s<double>("leading"),
      fontWeight: node.s<FontWeight>("fontWeight"),
      fontStyle: node.s<FontStyle>("fontStyle"),
      forceStrutHeight: node.s<bool>("forceStrutHeight"),
      debugLabel: node.s<String>("debugLabel"),
      package: node.s<String>("package")
    );
  }, mode: XMLLayout.Element);
  XMLLayout.reg("StrutStyle.fromTextStyle", (node, key) {
    return StrutStyle.fromTextStyle(
      node.child<TextStyle>(),
      fontFamily: node.s<String>("fontFamily"),
      fontFamilyFallback: node.s<String>("fontFamilyFallback")?.split(","),
      fontSize: node.s<double>("fontSize"),
      height: node.s<double>("height"),
      leading: node.s<double>("leading"),
      fontWeight: node.s<FontWeight>("fontWeight"),
      fontStyle: node.s<FontStyle>("fontStyle"),
      forceStrutHeight: node.s<bool>("forceStrutHeight"),
      debugLabel: node.s<String>("debugLabel"),
      package: node.s<String>("package")
    );
  });

}
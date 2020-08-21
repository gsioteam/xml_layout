
import 'dart:ui';

import '../xml_layout.dart';
import 'package:flutter/material.dart';

void reg() {
  XMLLayout.reg(Paint, (node, key) {
    if (node.name == "paint") {
      dynamic v;
      Paint paint = Paint();
      if ((v = node.s<bool>("isAntiAlias")) != null) paint.isAntiAlias = v;
      if ((v = node.s<Color>("color")) != null) paint.color = v;
      if ((v = node.s<BlendMode>("blendMode")) != null) paint.blendMode = v;
      if ((v = node.s<PaintingStyle>("style")) != null) paint.style = v;
      if ((v = node.s<double>("strokeWidth")) != null) paint.strokeWidth = v;
      if ((v = node.s<StrokeCap>("strokeCap")) != null) paint.strokeCap = v;
      if ((v = node.s<StrokeJoin>("strokeJoin")) != null) paint.strokeJoin = v;
      if ((v = node.s<double>("strokeMiterLimit")) != null) paint.strokeMiterLimit = v;
      if ((v = node.s<MaskFilter>("maskFilter")) != null) paint.maskFilter = v;
      if ((v = node.s<FilterQuality>("filterQuality")) != null) paint.filterQuality = v;
      if ((v = node.s<Shader>("shader")) != null) paint.shader = v;
      if ((v = node.s<ColorFilter>("colorFilter")) != null) paint.colorFilter = v;
      if ((v = node.s<ImageFilter>("imageFilter")) != null) paint.imageFilter = v;
      if ((v = node.s<bool>("invertColors")) != null) paint.invertColors = v;
    }
    return null;
  });

  XMLLayout.regEnum(BlendMode.values);
  XMLLayout.regEnum(FilterQuality.values);
  XMLLayout.regEnum(PaintingStyle.values);
  XMLLayout.regEnum(StrokeCap.values);
  XMLLayout.regEnum(StrokeJoin.values);
  
}
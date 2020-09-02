import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../xml_layout.dart';
import '../register.dart';
import 'rect.dart' as rect;

Register reg = Register(() {
  rect.reg();
  XmlLayout.reg(Image, (node, key) {
    return Image(
      key: key,
      image: node.s<ImageProvider>("image"),
      frameBuilder: node.s<ImageFrameBuilder>("frameBuilder"),
      errorBuilder: node.s<ImageErrorWidgetBuilder>("errorBuilder"),
      semanticLabel: node.s<String>("semanticLabel"),
      excludeFromSemantics: node.s<bool>("excludeFromSemantics", false),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
      color: node.s<Color>("color"),
      colorBlendMode: node.s<BlendMode>("colorBlendMode"),
      fit: node.s<BoxFit>("fit"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      repeat: node.s<ImageRepeat>("repeat", ImageRepeat.noRepeat),
      centerSlice: node.s<Rect>("centerSlice"),
      matchTextDirection: node.s<bool>("matchTextDirection", false),
      gaplessPlayback: node.s<bool>("gaplessPlayback", false),
      filterQuality: node.s<FilterQuality>("filterQuality", FilterQuality.low),
      loadingBuilder: node.s<ImageLoadingBuilder>("loadingBuilder"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.regEnum(ImageRepeat.values);
  XmlLayout.regEnum(FilterQuality.values);
  XmlLayout.reg("Image.network", (node, key) {
    return Image.network(
      node.s<String>("src"),
      key: key,
      frameBuilder: node.s<ImageFrameBuilder>("frameBuilder"),
      errorBuilder: node.s<ImageErrorWidgetBuilder>("errorBuilder"),
      semanticLabel: node.s<String>("semanticLabel"),
      excludeFromSemantics: node.s<bool>("excludeFromSemantics", false),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
      color: node.s<Color>("color"),
      colorBlendMode: node.s<BlendMode>("colorBlendMode"),
      fit: node.s<BoxFit>("fit"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      repeat: node.s<ImageRepeat>("repeat", ImageRepeat.noRepeat),
      centerSlice: node.s<Rect>("centerSlice"),
      matchTextDirection: node.s<bool>("matchTextDirection", false),
      gaplessPlayback: node.s<bool>("gaplessPlayback", false),
      filterQuality: node.s<FilterQuality>("filterQuality", FilterQuality.low),
      loadingBuilder: node.s<ImageLoadingBuilder>("loadingBuilder"),
      cacheWidth: node.s<int>("cacheWidth"),
      cacheHeight: node.s<int>("cacheHeight"),
      scale: node.s<double>("scale"),
      headers: node.s<Map<String, String>>("headers"),
    );
  });
  XmlLayout.reg("Image.file", (node, key) {
    return Image.file(
      node.s<File>("Image.file"),
      key: key,
      frameBuilder: node.s<ImageFrameBuilder>("frameBuilder"),
      errorBuilder: node.s<ImageErrorWidgetBuilder>("errorBuilder"),
      semanticLabel: node.s<String>("semanticLabel"),
      excludeFromSemantics: node.s<bool>("excludeFromSemantics", false),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
      color: node.s<Color>("color"),
      colorBlendMode: node.s<BlendMode>("colorBlendMode"),
      fit: node.s<BoxFit>("fit"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      repeat: node.s<ImageRepeat>("repeat", ImageRepeat.noRepeat),
      centerSlice: node.s<Rect>("centerSlice"),
      matchTextDirection: node.s<bool>("matchTextDirection", false),
      gaplessPlayback: node.s<bool>("gaplessPlayback", false),
      filterQuality: node.s<FilterQuality>("filterQuality", FilterQuality.low),
      cacheWidth: node.s<int>("cacheWidth"),
      cacheHeight: node.s<int>("cacheHeight"),
      scale: node.s<double>("scale"),
    );
  });
  XmlLayout.reg("Image.asset", (node, key) {
    return Image.asset(node.s<String>("name"),
        key: key,
        frameBuilder: node.s<ImageFrameBuilder>("frameBuilder"),
        errorBuilder: node.s<ImageErrorWidgetBuilder>("errorBuilder"),
        semanticLabel: node.s<String>("semanticLabel"),
        excludeFromSemantics: node.s<bool>("excludeFromSemantics", false),
        width: node.s<double>("width"),
        height: node.s<double>("height"),
        color: node.s<Color>("color"),
        colorBlendMode: node.s<BlendMode>("colorBlendMode"),
        fit: node.s<BoxFit>("fit"),
        alignment: node.s<Alignment>("alignment", Alignment.center),
        repeat: node.s<ImageRepeat>("repeat", ImageRepeat.noRepeat),
        centerSlice: node.s<Rect>("centerSlice"),
        matchTextDirection: node.s<bool>("matchTextDirection", false),
        gaplessPlayback: node.s<bool>("gaplessPlayback", false),
        filterQuality:
        node.s<FilterQuality>("filterQuality", FilterQuality.low),
        cacheWidth: node.s<int>("cacheWidth"),
        cacheHeight: node.s<int>("cacheHeight"),
        scale: node.s<double>("scale"),
        package: node.s<String>("package"));
  });
  XmlLayout.reg("Image.memory", (node, key) {
    return Image.memory(
      node.s<Uint8List>("bytes"),
      key: key,
      frameBuilder: node.s<ImageFrameBuilder>("frameBuilder"),
      errorBuilder: node.s<ImageErrorWidgetBuilder>("errorBuilder"),
      semanticLabel: node.s<String>("semanticLabel"),
      excludeFromSemantics: node.s<bool>("excludeFromSemantics", false),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
      color: node.s<Color>("color"),
      colorBlendMode: node.s<BlendMode>("colorBlendMode"),
      fit: node.s<BoxFit>("fit"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      repeat: node.s<ImageRepeat>("repeat", ImageRepeat.noRepeat),
      centerSlice: node.s<Rect>("centerSlice"),
      matchTextDirection: node.s<bool>("matchTextDirection", false),
      gaplessPlayback: node.s<bool>("gaplessPlayback", false),
      filterQuality: node.s<FilterQuality>("filterQuality", FilterQuality.low),
      cacheWidth: node.s<int>("cacheWidth"),
      cacheHeight: node.s<int>("cacheHeight"),
      scale: node.s<double>("scale"),
    );
  });

  XmlLayout.reg(ImageProvider, (node, key) {
    String url = node.text;
    if (RegExp("^https?://").hasMatch(url)) {
      return NetworkImage(url);
    } else {
      return FileImage(File(url));
    }
  }, mode: XmlLayout.Text);
  XmlLayout.reg(NetworkImage, (node, key) {
    return NetworkImage(
      node.s<String>("src"),
      scale: node.s<double>("scale"),
      headers: node.s<Map<String, String>>("headers")
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(FileImage, (node, key) {
    return FileImage(File(node.s<String>("src")),scale: node.s<double>("scale"),);
  }, mode: XmlLayout.Element);
});

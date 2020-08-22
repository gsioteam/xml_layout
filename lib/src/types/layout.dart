
import 'dart:ui';

import 'package:flutter/material.dart';

import '../xml_layout.dart';

void reg() {
  XMLLayout.regEnum(MainAxisAlignment.values);
  XMLLayout.regEnum(MainAxisSize.values);
  XMLLayout.regEnum(CrossAxisAlignment.values);
  XMLLayout.regEnum(VerticalDirection.values);
  XMLLayout.regEnum(Clip.values);

  XMLLayout.reg(Directionality, (node, key) {
    return Directionality(
      key: key,
      child: node.child<Widget>(),
      textDirection: node.s<TextDirection>("textDirection")
    );
  });

  XMLLayout.reg(Opacity, (node, key) {
    return Opacity(
      key: key,
      opacity: node.s<double>("opacity"),
      alwaysIncludeSemantics: node.s<bool>("alwaysIncludeSemantics"),
      child: node.child<Widget>(),
    );
  });

  XMLLayout.reg(ShaderMask, (node, key) {
    return ShaderMask(
      key: key,
      child: node.child<Widget>(),
      shaderCallback: node.s<ShaderCallback>("shaderCallback"),
      blendMode: node.s<BlendMode>("blendMode")
    );
  });

  XMLLayout.reg(BackdropFilter, (node, key) {
    return BackdropFilter(
      key: key,
      child: node.child<Widget>(),
      filter: node.s<ImageFilter>("filter")
    );
  });
  XMLLayout.reg(CustomPaint, (node, key) {
    return CustomPaint(
      key: key,
      child: node.child<Widget>(),
      painter: node.s<CustomPainter>("painter"),
      foregroundPainter: node.s<CustomPainter>("foregroundPainter"),
      size: node.s<Size>("size", Size.zero),
      isComplex: node.s<bool>("isComplex", false),
      willChange: node.s<bool>("willChange", false)
    );
  });
  XMLLayout.reg(ClipRect, (node, key) {
    return ClipRect(
      key: key,
      child: node.child<Widget>(),
      clipBehavior: node.s<Clip>("clipBehavior", Clip.hardEdge)
    );
  });
  XMLLayout.reg(ClipRRect, (node, key) {
    return ClipRRect(
      key: key,
      child: node.child<Widget>(),
      borderRadius: node.s<BorderRadius>("borderRadius"),
      clipper: node.s<CustomClipper<RRect>>("clipper"),
      clipBehavior: node.s<Clip>("clipBehavior", Clip.antiAlias)
    );
  });

  XMLLayout.reg(ClipOval, (node, key) {
    return ClipOval(
      key: key,
      child: node.child<Widget>(),
      clipBehavior: node.s<Clip>("clipBehavior", Clip.antiAlias),
    );
  });
  XMLLayout.reg(ClipPath, (node, key) {
    return ClipPath(
      key: key,
      child: node.child<Widget>(),
      clipBehavior: node.s<Clip>("clipBehavior", Clip.antiAlias),
      clipper: node.s<CustomClipper<Path>>("clipper")
    );
  });
  XMLLayout.reg(PhysicalModel, (node, key) {
    return PhysicalModel(
      key: key,
      child: node.child<Widget>(),
      shape: node.s<BoxShape>("shape", BoxShape.rectangle),
      clipBehavior: node.s<Clip>("clipBehavior", Clip.none),
      borderRadius: node.s<BorderRadius>("borderRadius"),
      elevation: node.s<double>("elevation", 0.0),
      color: node.s<Color>("color"),
      shadowColor: node.s<Color>("shadowColor", Colors.black)
    );
  });
  XMLLayout.reg(PhysicalShape, (node, key) {
    return PhysicalShape(
      key: key,
      child: node.child<Widget>(),
      clipper: node.s<CustomClipper<Path>>("clipper"),
      clipBehavior: node.s<Clip>("clipBehavior", Clip.none),
      elevation: node.s<double>("elevation", 0.0),
      color: node.s<Color>("color"),
      shadowColor: node.s<Color>("shadowColor", Colors.black)
    );
  });
  XMLLayout.reg(Transform, (node, key) {
    return Transform(
      key: key,
      child: node.child<Widget>(),
      transform: node.s<Matrix4>("transform"),
      origin: node.s<Offset>("origin"),
      alignment: node.s<AlignmentGeometry>("alignment"),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  }, mode: XMLLayout.Element);
  XMLLayout.reg("Transform.rotate", (node, key) {
    return Transform.rotate(
      key: key,
      child: node.child<Widget>(),
      angle: node.s<double>("angle"),
      origin: node.s<Offset>("origin"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  });
  XMLLayout.reg("Transform.translate", (node, key) {
    return Transform.translate(
      key: key,
      child: node.child<Widget>(),
      offset: node.s<Offset>("offset"),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  });
  XMLLayout.reg("Transform.scale", (node, key) {
    return Transform.scale(
      key: key,
      child: node.child<Widget>(),
      scale: node.s<double>("scale"),
      origin: node.s<Offset>("origin"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  });
  XMLLayout.reg(CompositedTransformTarget, (node, key) {
    return CompositedTransformTarget(
      key: key,
      child: node.child<Widget>(),
      link: node.s<LayerLink>("link"),
    );
  });

  XMLLayout.reg(Row, (node, key) {
    return Row(
      key: key,
      children: node.children<Widget>(),
      mainAxisAlignment: node.s<MainAxisAlignment>("mainAxisAlignment", MainAxisAlignment.start),
      mainAxisSize: node.s<MainAxisSize>("mainAxisSize", MainAxisSize.max),
      crossAxisAlignment: node.s<CrossAxisAlignment>("crossAxisAlignment", CrossAxisAlignment.center),
      textDirection: node.s<TextDirection>("textDirection"),
      verticalDirection: node.s<VerticalDirection>("verticalDirection", VerticalDirection.down),
      textBaseline: node.s<TextBaseline>("textBaseline"),
    );
  });

  XMLLayout.reg(BorderRadius, (node, key) {
    switch (node.text) {
      case 'zero': return BorderRadius.zero;
      default: {
        List<String> params;
        if ((params = node.splitMethod("all", 1)) != null) {
          return BorderRadius.all(node.v<Radius>(params[0]));
        } else if ((params = node.splitMethod("circular", 1)) != null) {
          return BorderRadius.circular(double.parse(params[0]));
        } else if ((params = node.splitMethod("vertical", 2)) != null) {
          return BorderRadius.vertical(
            top: node.v<Radius>(params[0]),
            bottom: node.v<Radius>(params[1])
          );
        } else if ((params = node.splitMethod("horizontal", 2)) != null) {
          return BorderRadius.horizontal(
              left: node.v<Radius>(params[0]),
              right: node.v<Radius>(params[1])
          );
        } else if ((params = node.splitMethod("only", 4)) != null) {
          return BorderRadius.only(
            topLeft: node.v<Radius>(params[0]),
            topRight: node.v<Radius>(params[1]),
            bottomLeft: node.v<Radius>(params[2]),
            bottomRight: node.v<Radius>(params[3]),
          );
        }
        return null;
      }
    }
  }, mode: XMLLayout.Text);

  XMLLayout.reg(Radius, (node, key) {
    switch (node.text) {
      case 'zero': return Radius.zero;
      default: {
        List<String> params;
        if ((params = node.splitMethod("circular", 1)) != null) {
          return Radius.circular(double.parse(params[0]));
        } else if ((params = node.splitMethod("elliptical", 2)) != null) {
          return Radius.elliptical(double.parse(params[0]), double.parse(params[1]));
        }
        return null;
      }
    }
  }, mode: XMLLayout.Text);
  XMLLayout.reg(Offset, (node, key) {
    switch (node.text) {
      case 'zero': return Offset.zero;
      case 'infinite': return Offset.infinite;
      default: {
        List<String> params;
        if ((params = node.splitMethod("", 2)) != null) {
          return Offset(double.parse(params[0]), double.parse(params[1]));
        } else if ((params = node.splitMethod("fromDirection", 1)) != null) {
          return Offset.fromDirection(double.parse(params[0]));
        } else if ((params = node.splitMethod("fromDirection", 2)) != null) {
          return Offset.fromDirection(double.parse(params[0]), double.parse(params[1]));
        }
        return null;
      }
    }
  }, mode: XMLLayout.Text);
}
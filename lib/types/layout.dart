import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../parser.dart';
import '../xml_layout.dart';

void reg() {
  XmlLayout.regEnum(MainAxisAlignment.values);
  XmlLayout.regEnum(MainAxisSize.values);
  XmlLayout.regEnum(CrossAxisAlignment.values);
  XmlLayout.regEnum(VerticalDirection.values);
  XmlLayout.regEnum(Clip.values);

  XmlLayout.reg(Directionality, (node, key) {
    return Directionality(
        key: key,
        child: node.child<Widget>(),
        textDirection: node.s<TextDirection>("textDirection"));
  }, mode: XmlLayout.Element);

  XmlLayout.reg(Opacity, (node, key) {
    return Opacity(
      key: key,
      opacity: node.s<double>("opacity"),
      alwaysIncludeSemantics: node.s<bool>("alwaysIncludeSemantics"),
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);

  XmlLayout.reg(ShaderMask, (node, key) {
    return ShaderMask(
        key: key,
        child: node.child<Widget>(),
        shaderCallback: node.s<ShaderCallback>("shaderCallback"),
        blendMode: node.s<BlendMode>("blendMode"));
  }, mode: XmlLayout.Element);

  XmlLayout.reg(BackdropFilter, (node, key) {
    return BackdropFilter(
        key: key,
        child: node.child<Widget>(),
        filter: node.s<ui.ImageFilter>("filter"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(CustomPaint, (node, key) {
    return CustomPaint(
        key: key,
        child: node.child<Widget>(),
        painter: node.s<CustomPainter>("painter"),
        foregroundPainter: node.s<CustomPainter>("foregroundPainter"),
        size: node.s<Size>("size", Size.zero),
        isComplex: node.s<bool>("isComplex", false),
        willChange: node.s<bool>("willChange", false));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ClipRect, (node, key) {
    return ClipRect(
        key: key,
        child: node.child<Widget>(),
        clipBehavior: node.s<Clip>("clipBehavior", Clip.hardEdge));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ClipRRect, (node, key) {
    return ClipRRect(
        key: key,
        child: node.child<Widget>(),
        borderRadius: node.s<BorderRadius>("borderRadius"),
        clipper: node.s<CustomClipper<RRect>>("clipper"),
        clipBehavior: node.s<Clip>("clipBehavior", Clip.antiAlias));
  }, mode: XmlLayout.Element);

  XmlLayout.reg(ClipOval, (node, key) {
    return ClipOval(
      key: key,
      child: node.child<Widget>(),
      clipBehavior: node.s<Clip>("clipBehavior", Clip.antiAlias),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ClipPath, (node, key) {
    return ClipPath(
        key: key,
        child: node.child<Widget>(),
        clipBehavior: node.s<Clip>("clipBehavior", Clip.antiAlias),
        clipper: node.s<CustomClipper<Path>>("clipper"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(PhysicalModel, (node, key) {
    return PhysicalModel(
        key: key,
        child: node.child<Widget>(),
        shape: node.s<BoxShape>("shape", BoxShape.rectangle),
        clipBehavior: node.s<Clip>("clipBehavior", Clip.none),
        borderRadius: node.s<BorderRadius>("borderRadius"),
        elevation: node.s<double>("elevation", 0.0),
        color: node.s<Color>("color"),
        shadowColor: node.s<Color>("shadowColor", Colors.black));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(PhysicalShape, (node, key) {
    return PhysicalShape(
        key: key,
        child: node.child<Widget>(),
        clipper: node.s<CustomClipper<Path>>("clipper"),
        clipBehavior: node.s<Clip>("clipBehavior", Clip.none),
        elevation: node.s<double>("elevation", 0.0),
        color: node.s<Color>("color"),
        shadowColor: node.s<Color>("shadowColor", Colors.black));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Transform, (node, key) {
    return Transform(
      key: key,
      child: node.child<Widget>(),
      transform: node.s<Matrix4>("transform"),
      origin: node.s<Offset>("origin"),
      alignment: node.s<AlignmentGeometry>("alignment"),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Transform.rotate", (node, key) {
    return Transform.rotate(
      key: key,
      child: node.child<Widget>(),
      angle: node.s<double>("angle"),
      origin: node.s<Offset>("origin"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Transform.translate", (node, key) {
    return Transform.translate(
      key: key,
      child: node.child<Widget>(),
      offset: node.s<Offset>("offset"),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Transform.scale", (node, key) {
    return Transform.scale(
      key: key,
      child: node.child<Widget>(),
      scale: node.s<double>("scale"),
      origin: node.s<Offset>("origin"),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      transformHitTests: node.s<bool>("transformHitTests", true),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(CompositedTransformTarget, (node, key) {
    return CompositedTransformTarget(
      key: key,
      child: node.child<Widget>(),
      link: node.s<LayerLink>("link"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(CompositedTransformFollower, (node, key) {
    return CompositedTransformFollower(
      key: key,
      child: node.child<Widget>(),
      link: node.s<LayerLink>("link"),
      showWhenUnlinked: node.s<bool>("showWhenUnlinked"),
      offset: node.s<Offset>("offset", Offset.zero),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(FittedBox, (node, key) {
    return FittedBox(
        key: key,
        child: node.child<Widget>(),
        fit: node.s<BoxFit>("fit", BoxFit.contain),
        alignment: node.s<Alignment>("alignment", Alignment.center));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(FractionalTranslation, (node, key) {
    return FractionalTranslation(
        key: key,
        child: node.child<Widget>(),
        translation: node.s<Offset>("translation"),
        transformHitTests: node.s<bool>("transformHitTests"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(RotatedBox, (node, key) {
    return RotatedBox(
        key: key,
        child: node.child<Widget>(),
        quarterTurns: node.s<int>("quarterTurns"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Padding, (node, key) {
    return Padding(
        key: key,
        child: node.child<Widget>(),
        padding: node.s<EdgeInsetsGeometry>("padding"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Align, (node, key) {
    return Align(
      key: key,
      child: node.child<Widget>(),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      widthFactor: node.s<double>("widthFactor"),
      heightFactor: node.s<double>("heightFactor"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Center, (node, key) {
    return Center(
      key: key,
      child: node.child<Widget>(),
      widthFactor: node.s<double>("widthFactor"),
      heightFactor: node.s<double>("heightFactor"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(CustomSingleChildLayout, (node, key) {
    return CustomSingleChildLayout(
        key: key,
        child: node.child<Widget>(),
        delegate: node.s<SingleChildLayoutDelegate>("delegate"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(LayoutId, (node, key) {
    return LayoutId(
        key: key, child: node.child<Widget>(), id: node.s<Object>("id"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(CustomMultiChildLayout, (node, key) {
    return CustomMultiChildLayout(
      key: key,
      children: node.children<Widget>(),
      delegate: node.s<MultiChildLayoutDelegate>("delegate"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(SizedBox, (node, key) {
    return SizedBox(
      key: key,
      child: node.child<Widget>(),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("SizedBox.expand", (node, key) {
    return SizedBox.expand(
      key: key,
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("SizedBox.shrink", (node, key) {
    return SizedBox.shrink(
      key: key,
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("SizedBox.fromSize", (node, key) {
    return SizedBox.fromSize(
      key: key,
      child: node.child<Widget>(),
      size: node.s<Size>("size"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ConstrainedBox, (node, key) {
    return ConstrainedBox(
      key: key,
      child: node.child<Widget>(),
      constraints: node.s<BoxConstraints>("constraints"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(UnconstrainedBox, (node, key) {
    return UnconstrainedBox(
        key: key,
        child: node.child<Widget>(),
        textDirection: node.s<TextDirection>("textDirection"),
        alignment: node.s<Alignment>("alignment", Alignment.center),
        constrainedAxis: node.s<Axis>("constrainedAxis"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(FractionallySizedBox, (node, key) {
    return FractionallySizedBox(
      key: key,
      child: node.child<Widget>(),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      widthFactor: node.s<double>("widthFactor"),
      heightFactor: node.s<double>("heightFactor"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(LimitedBox, (node, key) {
    return LimitedBox(
      key: key,
      child: node.child<Widget>(),
      maxWidth: node.s<double>("maxWidth", double.infinity),
      maxHeight: node.s<double>("maxHeight", double.infinity),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(OverflowBox, (node, key) {
    return OverflowBox(
      key: key,
      child: node.child<Widget>(),
      alignment: node.s<Alignment>("alignment", Alignment.center),
      minWidth: node.s<double>("minWidth"),
      maxWidth: node.s<double>("maxWidth"),
      minHeight: node.s<double>("minHeight"),
      maxHeight: node.s<double>("maxHeight"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(SizedOverflowBox, (node, key) {
    return SizedOverflowBox(
        key: key,
        child: node.child<Widget>(),
        size: node.s<Size>("size"),
        alignment: node.s<Alignment>("alignment", Alignment.center));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Offstage, (node, key) {
    return Offstage(
        key: key,
        child: node.child<Widget>(),
        offstage: node.s<bool>("offstage", true));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(AspectRatio, (node, key) {
    return AspectRatio(
        key: key,
        child: node.child<Widget>(),
        aspectRatio: node.s<double>("aspectRatio"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(IntrinsicWidth, (node, key) {
    return IntrinsicWidth(
        key: key,
        child: node.child<Widget>(),
        stepWidth: node.s<double>("stepWidth"),
        stepHeight: node.s<double>("stepHeight"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(IntrinsicHeight, (node, key) {
    return IntrinsicHeight(
      key: key,
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Baseline, (node, key) {
    return Baseline(
        key: key,
        child: node.child<Widget>(),
        baseline: node.s<double>("baseline"),
        baselineType: node.s<TextBaseline>("baselineType"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(SliverToBoxAdapter, (node, key) {
    return SliverToBoxAdapter(
      key: key,
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(SliverPadding, (node, key) {
    return SliverPadding(
        key: key,
        sliver: node.child<Widget>(),
        padding: node.s<EdgeInsetsGeometry>("padding"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ListBody, (node, key) {
    return ListBody(
        key: key,
        children: node.children<Widget>(),
        mainAxis: node.s<Axis>("mainAxis", Axis.vertical),
        reverse: node.s<bool>("reverse", false));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Stack, (node, key) {
    return Stack(
        key: key,
        children: node.children<Widget>(),
        alignment: node.s<AlignmentDirectional>(
            "alignment", AlignmentDirectional.topStart),
        textDirection: node.s<TextDirection>("textDirection"),
        fit: node.s<StackFit>("fit", StackFit.loose),
        overflow: node.s<Overflow>("overflow", Overflow.clip));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(IndexedStack, (node, key) {
    return IndexedStack(
        key: key,
        children: node.children<Widget>(),
        alignment: node.s<AlignmentDirectional>(
            "alignment", AlignmentDirectional.topStart),
        textDirection: node.s<TextDirection>("textDirection"),
        sizing: node.s<StackFit>("sizing", StackFit.loose),
        index: node.s<int>("index", 0));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Positioned, (node, key) {
    return Positioned(
      key: key,
      child: node.child<Widget>(),
      left: node.s<double>("left"),
      top: node.s<double>("top"),
      right: node.s<double>("right"),
      bottom: node.s<double>("bottom"),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Positioned.fromRect", (node, key) {
    return Positioned.fromRect(
      key: key,
      child: node.child<Widget>(),
      rect: node.s<Rect>("rect"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Positioned.fromRelativeRect", (node, key) {
    return Positioned.fromRelativeRect(
      key: key,
      child: node.child<Widget>(),
      rect: node.s<RelativeRect>("rect"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Positioned.fill", (node, key) {
    return Positioned.fill(
      key: key,
      child: node.child<Widget>(),
      left: node.s<double>("left", 0.0),
      right: node.s<double>("right", 0.0),
      top: node.s<double>("top", 0.0),
      bottom: node.s<double>("bottom", 0.0),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Positioned.directional", (node, key) {
    return Positioned.directional(
      key: key,
      child: node.child<Widget>(),
      textDirection: node.s<TextDirection>("textDirection"),
      start: node.s<double>("start"),
      top: node.s<double>("top"),
      end: node.s<double>("end"),
      bottom: node.s<double>("bottom"),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(PositionedDirectional, (node, key) {
    return PositionedDirectional(
      key: key,
      child: node.child<Widget>(),
      start: node.s<double>("start"),
      end: node.s<double>("end"),
      top: node.s<double>("top"),
      bottom: node.s<double>("bottom"),
      width: node.s<double>("width"),
      height: node.s<double>("height"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Flex, (node, key) {
    return Flex(
        key: key,
        children: node.children<Widget>(),
        direction: node.s<Axis>("direction"),
        mainAxisAlignment: node.s<MainAxisAlignment>(
            "mainAxisAlignment", MainAxisAlignment.start),
        mainAxisSize: node.s<MainAxisSize>("mainAxisSize", MainAxisSize.max),
        crossAxisAlignment: node.s<CrossAxisAlignment>(
            "crossAxisAlignment", CrossAxisAlignment.center),
        textDirection: node.s<TextDirection>("textDirection"),
        verticalDirection: node.s<VerticalDirection>(
            "verticalDirection", VerticalDirection.down),
        textBaseline: node.s<TextBaseline>("textBaseline"));
  }, mode: XmlLayout.Element);

  XmlLayout.reg(Row, (node, key) {
    return Row(
      key: key,
      children: node.children<Widget>(),
      mainAxisAlignment: node.s<MainAxisAlignment>(
          "mainAxisAlignment", MainAxisAlignment.start),
      mainAxisSize: node.s<MainAxisSize>("mainAxisSize", MainAxisSize.max),
      crossAxisAlignment: node.s<CrossAxisAlignment>(
          "crossAxisAlignment", CrossAxisAlignment.center),
      textDirection: node.s<TextDirection>("textDirection"),
      verticalDirection: node.s<VerticalDirection>(
          "verticalDirection", VerticalDirection.down),
      textBaseline: node.s<TextBaseline>("textBaseline"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Column, (node, key) {
    return Column(
      key: key,
      children: node.children<Widget>(),
      mainAxisAlignment: node.s<MainAxisAlignment>(
          "mainAxisAlignment", MainAxisAlignment.start),
      mainAxisSize: node.s<MainAxisSize>("mainAxisSize", MainAxisSize.max),
      crossAxisAlignment: node.s<CrossAxisAlignment>(
          "crossAxisAlignment", CrossAxisAlignment.center),
      textDirection: node.s<TextDirection>("textDirection"),
      verticalDirection: node.s<VerticalDirection>(
          "verticalDirection", VerticalDirection.down),
      textBaseline: node.s<TextBaseline>("textBaseline"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Flexible, (node, key) {
    return Flexible(
      key: key,
      child: node.child<Widget>(),
      flex: node.s<int>("flex", 1),
      fit: node.s<FlexFit>("fit", FlexFit.loose),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Expanded, (node, key) {
    return Expanded(
      key: key,
      child: node.child<Widget>(),
      flex: node.s<int>("flex", 1),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Wrap, (node, key) {
    return Wrap(
      key: key,
      children: node.children<Widget>(),
      direction: node.s<Axis>("direction", Axis.horizontal),
      alignment: node.s<WrapAlignment>("alignment", WrapAlignment.start),
      spacing: node.s<double>("spacing", 0),
      runAlignment: node.s<WrapAlignment>("runAlignment", WrapAlignment.start),
      runSpacing: node.s<double>("runSpacing", 0),
      crossAxisAlignment: node.s<WrapCrossAlignment>(
          "crossAxisAlignment", WrapCrossAlignment.start),
      textDirection: node.s<TextDirection>("textDirection"),
      verticalDirection: node.s<VerticalDirection>(
          "verticalDirection", VerticalDirection.down),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Flow, (node, key) {
    return Flow(
      key: key,
      children: node.children<Widget>(),
      delegate: node.s<FlowDelegate>("delegate"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("Flow.unwrapped", (node, key) {
    return Flow.unwrapped(
      key: key,
      children: node.children<Widget>(),
      delegate: node.s<FlowDelegate>("delegate"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(RichText, (node, key) {
    return RichText(
      key: key,
      text: node.child<InlineSpan>(),
      textAlign: node.s<TextAlign>("textAlign", TextAlign.start),
      textDirection: node.s<TextDirection>("textDirection"),
      softWrap: node.s<bool>("softWrap", true),
      overflow: node.s<TextOverflow>("overflow", TextOverflow.clip),
      textScaleFactor: node.s<double>("textScaleFactor", 1),
      maxLines: node.s<int>("maxLines"),
      locale: node.s<Locale>("locale"),
      strutStyle: node.s<StrutStyle>("strutStyle"),
      textWidthBasis:
          node.s<TextWidthBasis>("textWidthBasis", TextWidthBasis.parent),
      textHeightBehavior: node.s<TextHeightBehavior>("textHeightBehavior"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(RawImage, (node, key) {
    return RawImage(
        key: key,
        image: node.child<ui.Image>(),
        width: node.s<double>("width"),
        height: node.s<double>("height"),
        scale: node.s<double>("scale", 1),
        color: node.s<Color>("color"),
        colorBlendMode: node.s<BlendMode>("colorBlendMode"),
        fit: node.s<BoxFit>("fit"),
        alignment: node.s<Alignment>("alignment", Alignment.center),
        repeat: node.s<ImageRepeat>("repeat", ImageRepeat.noRepeat),
        centerSlice: node.s<Rect>("centerSlice"),
        matchTextDirection: node.s<bool>("matchTextDirection", false),
        invertColors: node.s<bool>("invertColors", false),
        filterQuality:
            node.s<FilterQuality>("filterQuality", FilterQuality.low));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(DefaultAssetBundle, (node, key) {
    return DefaultAssetBundle(
      key: key,
      child: node.child<Widget>(),
      bundle: node.s<AssetBundle>("bundle"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Listener, (node, key) {
    return Listener(
        key: key,
        child: node.child<Widget>(),
        onPointerDown: node.s<PointerDownEventListener>("onPointerDown"),
        onPointerMove: node.s<PointerMoveEventListener>("onPointerMove"),
        onPointerUp: node.s<PointerUpEventListener>("onPointerUp"),
        onPointerCancel: node.s<PointerCancelEventListener>("onPointerCancel"),
        onPointerSignal: node.s<PointerSignalEventListener>("onPointerSignal"),
        behavior:
            node.s<HitTestBehavior>("behavior", HitTestBehavior.deferToChild));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(MouseRegion, (node, key) {
    return MouseRegion(
      key: key,
      child: node.child<Widget>(),
      onEnter: node.s<PointerEnterEventListener>("onEnter"),
      onHover: node.s<PointerHoverEventListener>("onHover"),
      onExit: node.s<PointerExitEventListener>("onExit"),
      opaque: node.s<bool>("opaque", true),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(RepaintBoundary, (node, key) {
    return RepaintBoundary(
      key: key,
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(IgnorePointer, (node, key) {
    return IgnorePointer(
        key: key,
        child: node.child<Widget>(),
        ignoring: node.s<bool>("ignoring", true),
        ignoringSemantics: node.s<bool>("ignoringSemantics"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(AbsorbPointer, (node, key) {
    return AbsorbPointer(
        key: key,
        child: node.child<Widget>(),
        absorbing: node.s<bool>("absorbing", true),
        ignoringSemantics: node.s<bool>("ignoringSemantics"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(MetaData, (node, key) {
    return MetaData(
        key: key,
        child: node.child<Widget>(),
        behavior:
            node.s<HitTestBehavior>("behavior", HitTestBehavior.deferToChild),
        metaData: node.s("metaData"));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(Semantics, (node, key) {
    return Semantics(
      key: key,
      child: node.child<Widget>(),
      container: node.s<bool>("container", false),
      explicitChildNodes: node.s<bool>("explicitChildNodes", false),
      excludeSemantics: node.s<bool>("excludeSemantics", false),
      enabled: node.s<bool>("enabled"),
      checked: node.s<bool>("checked"),
      selected: node.s<bool>("selected"),
      toggled: node.s<bool>("toggled"),
      button: node.s<bool>("button"),
      link: node.s<bool>("link"),
      header: node.s<bool>("header"),
      textField: node.s<bool>("textField"),
      readOnly: node.s<bool>("readOnly"),
      focusable: node.s<bool>("focusable"),
      focused: node.s<bool>("focused"),
      inMutuallyExclusiveGroup: node.s<bool>("inMutuallyExclusiveGroup"),
      obscured: node.s<bool>("obscured"),
      multiline: node.s<bool>("multiline"),
      scopesRoute: node.s<bool>("scopesRoute"),
      namesRoute: node.s<bool>("namesRoute"),
      hidden: node.s<bool>("hidden"),
      image: node.s<bool>("image"),
      liveRegion: node.s<bool>("liveRegion"),
      maxValueLength: node.s<int>("maxValueLength"),
      currentValueLength: node.s<int>("currentValueLength"),
      label: node.s<String>("label"),
      value: node.s<String>("value"),
      increasedValue: node.s<String>("increasedValue"),
      decreasedValue: node.s<String>("decreasedValue"),
      hint: node.s<String>("hint"),
      onTapHint: node.s<String>("onTapHint"),
      onLongPressHint: node.s<String>("onLongPressHint"),
      textDirection: node.s<TextDirection>("textDirection"),
      sortKey: node.s<SemanticsSortKey>("sortKey"),
      onTap: node.s<VoidCallback>("onTap"),
      onLongPress: node.s<VoidCallback>("onLongPress"),
      onScrollLeft: node.s<VoidCallback>("onScrollLeft"),
      onScrollRight: node.s<VoidCallback>("onScrollRight"),
      onScrollUp: node.s<VoidCallback>("onScrollUp"),
      onScrollDown: node.s<VoidCallback>("onScrollDown"),
      onIncrease: node.s<VoidCallback>("onIncrease"),
      onDecrease: node.s<VoidCallback>("onDecrease"),
      onCopy: node.s<VoidCallback>("onCopy"),
      onCut: node.s<VoidCallback>("onCut"),
      onPaste: node.s<VoidCallback>("onPaste"),
      onDismiss: node.s<VoidCallback>("onDismiss"),
      onMoveCursorForwardByCharacter:
          node.s<MoveCursorHandler>("onMoveCursorForwardByCharacter"),
      onMoveCursorBackwardByCharacter:
          node.s<MoveCursorHandler>("onMoveCursorBackwardByCharacter"),
      onSetSelection: node.s<SetSelectionHandler>("onSetSelection"),
      onDidGainAccessibilityFocus:
          node.s<VoidCallback>("onDidGainAccessibilityFocus"),
      onDidLoseAccessibilityFocus:
          node.s<VoidCallback>("onDidLoseAccessibilityFocus"),
      customSemanticsActions: node.s<Map<CustomSemanticsAction, VoidCallback>>(
          "customSemanticsActions"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(MergeSemantics, (node, key) {
    return MergeSemantics(
      key: key,
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(BlockSemantics, (node, key) {
    return BlockSemantics(
      key: key,
      child: node.child<Widget>(),
      blocking: node.s<bool>("blocking", true),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ExcludeSemantics, (node, key) {
    return ExcludeSemantics(
      key: key,
      child: node.child<Widget>(),
      excluding: node.s<bool>("excluding", true),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(IndexedSemantics, (node, key) {
    return IndexedSemantics(
      key: key,
      child: node.child<Widget>(),
      index: node.s<int>("index"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(KeyedSubtree, (node, key) {
    return KeyedSubtree(
      key: key,
      child: node.child<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("KeyedSubtree.wrap", (node, key) {
    return KeyedSubtree.wrap(node.child<Widget>(), node.s<int>("index"));
  });
  XmlLayout.reg(Builder, (node, key) {
    return Builder(
      key: key,
      builder: node.s<WidgetBuilder>("builder"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(StatefulBuilder, (node, key) {
    return StatefulBuilder(
      key: key,
      builder: node.s<StatefulWidgetBuilder>("builder"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ColoredBox, (node, key) {
    return ColoredBox(
      key: key,
      child: node.child<Widget>(),
      color: node.s<Color>("color"),
    );
  }, mode: XmlLayout.Element);

  XmlLayout.reg(BorderRadius, (node, key) {
    switch (node.text) {
      case 'zero':
        return BorderRadius.zero;
      default:
        {
          MethodNode params;
          if ((params = node.splitMethod("all", 1)) != null) {
            return BorderRadius.all(node.v<Radius>(params[0]));
          } else if ((params = node.splitMethod("circular", 1)) != null) {
            return BorderRadius.circular(double.parse(params[0]));
          } else if ((params = node.splitMethod("vertical", 2)) != null) {
            return BorderRadius.vertical(
                top: node.v<Radius>(params[0]),
                bottom: node.v<Radius>(params[1]));
          } else if ((params = node.splitMethod("horizontal", 2)) != null) {
            return BorderRadius.horizontal(
                left: node.v<Radius>(params[0]),
                right: node.v<Radius>(params[1]));
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
  }, mode: XmlLayout.Text);

  XmlLayout.reg(Radius, (node, key) {
    switch (node.text) {
      case 'zero':
        return Radius.zero;
      default:
        {
          MethodNode params;
          if ((params = node.splitMethod("circular", 1)) != null) {
            return Radius.circular(double.parse(params[0]));
          } else if ((params = node.splitMethod("elliptical", 2)) != null) {
            return Radius.elliptical(
                double.parse(params[0]), double.parse(params[1]));
          }
          return null;
        }
    }
  }, mode: XmlLayout.Text);
  XmlLayout.reg(Offset, (node, key) {
    switch (node.text) {
      case 'zero':
        return Offset.zero;
      case 'infinite':
        return Offset.infinite;
      default:
        {
          MethodNode params;
          if ((params = node.splitMethod("", 2)) != null) {
            return Offset(double.parse(params[0]), double.parse(params[1]));
          } else if ((params = node.splitMethod("fromDirection", 1)) != null) {
            return Offset.fromDirection(double.parse(params[0]));
          } else if ((params = node.splitMethod("fromDirection", 2)) != null) {
            return Offset.fromDirection(
                double.parse(params[0]), double.parse(params[1]));
          }
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
  XmlLayout.reg(BoxConstraints, (node, key) {
    MethodNode a;
    if ((a = node.splitMethod("", 4)) != null) {
      return BoxConstraints(
          minWidth: double.tryParse(a[0]),
          minHeight: double.tryParse(a[1]),
          maxWidth: double.tryParse(a[2]),
          maxHeight: double.tryParse(a[3]));
    } else if ((a = node.splitMethod("tight", 1)) != null) {
      return BoxConstraints.tight(node.v<Size>(a[0]));
    } else if ((a = node.splitMethod("tightFor", 2)) != null) {
      return BoxConstraints.tightFor(
          width: double.tryParse(a[0]), height: double.tryParse(a[1]));
    } else if ((a = node.splitMethod("tightForFinite", 2)) != null) {
      return BoxConstraints.tightForFinite(
          width: double.tryParse(a[0]) ?? double.infinity,
          height: double.tryParse(a[1]) ?? double.infinity);
    } else if ((a = node.splitMethod("loose", 1)) != null) {
      return BoxConstraints.loose(node.v<Size>(a[0]));
    } else if ((a = node.splitMethod("expand", 2)) != null) {
      return BoxConstraints.expand(
          width: double.tryParse(a[0]), height: double.tryParse(a[1]));
    } else {
      return null;
    }
  }, mode: XmlLayout.Text);
  XmlLayout.regEnum(Axis.values);
  XmlLayout.reg(AlignmentDirectional, (node, key) {
    switch (node.text) {
      case 'topStart':
        return AlignmentDirectional.topStart;
      case 'topCenter':
        return AlignmentDirectional.topCenter;
      case 'topEnd':
        return AlignmentDirectional.topEnd;
      case 'centerStart':
        return AlignmentDirectional.centerStart;
      case 'center':
        return AlignmentDirectional.center;
      case 'centerEnd':
        return AlignmentDirectional.centerEnd;
      case 'bottomStart':
        return AlignmentDirectional.bottomStart;
      case 'bottomCenter':
        return AlignmentDirectional.bottomCenter;
      case 'bottomEnd':
        return AlignmentDirectional.bottomEnd;
      default:
        {
          var a = node.splitMethod("", 2);
          if (a == null) {
            return null;
          } else {
            return AlignmentDirectional(
                double.tryParse(a[0]), double.tryParse(a[1]));
          }
        }
    }
  }, mode: XmlLayout.Text);
  XmlLayout.regEnum(StackFit.values);
  XmlLayout.regEnum(Overflow.values);
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
  XmlLayout.reg(Alignment, (node, key) {
    switch (node.text) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        {
          MethodNode a;
          if ((a = node.splitMethod("", 2)) != null) {
            return Alignment(double.tryParse(a[0]), double.tryParse(a[1]));
          } else
            return null;
        }
    }
  }, mode: XmlLayout.Text);
  XmlLayout.regEnum(HitTestBehavior.values);
  XmlLayout.regEnum(BoxFit.values);

  XmlLayout.reg(AlignmentGeometry, (node, _) {
    String text = node.text;
    switch (text) {
      case "topLeft":
        return Alignment.topLeft;
      case "topCenter":
        return Alignment.topCenter;
      case "topRight":
        return Alignment.topRight;
      case "centerLeft":
        return Alignment.centerLeft;
      case "center":
        return Alignment.center;
      case "centerRight":
        return Alignment.centerRight;
      case "bottomLeft":
        return Alignment.bottomLeft;
      case "bottomCenter":
        return Alignment.bottomCenter;
      case "bottomRight":
        return Alignment.bottomRight;
      case "topStart":
        return AlignmentDirectional.topStart;
      case "topEnd":
        return AlignmentDirectional.topEnd;
      case "centerStart":
        return AlignmentDirectional.centerStart;
      case "centerEnd":
        return AlignmentDirectional.centerEnd;
      case "bottomStart":
        return AlignmentDirectional.bottomStart;
      case "bottomEnd":
        return AlignmentDirectional.bottomEnd;
      default:
        {
          List<String> arr = text.split(",");
          if (arr.length >= 2) {
            return Alignment(double.parse(arr[0]), double.parse(arr[1]));
          }
        }
    }
    return null;
  });

  XmlLayout.reg(EdgeInsetsGeometry, (node, _) {
    switch (node.text) {
      case 'infinity':
        return EdgeInsetsGeometry.infinity;
      case 'zero':
        return EdgeInsets.zero;
      default:
        {
          MethodNode a;
          if ((a = node.splitMethod("all", 1)) != null) {
            return EdgeInsets.all(double.tryParse(a[0]));
          } else if ((a = node.splitMethod("only", 4)) != null) {
            return EdgeInsets.only(
              left: double.tryParse(a[0]),
              top: double.tryParse(a[1]),
              right: double.tryParse(a[2]),
              bottom: double.tryParse(a[3]),
            );
          } else if ((a = node.splitMethod("symmetric", 2)) != null) {
            return EdgeInsets.symmetric(
                vertical: double.tryParse(a[0]),
                horizontal: double.tryParse(a[1]));
          } else if ((a = node.splitMethod("fromWindowPadding", 2)) != null) {
            return EdgeInsets.fromWindowPadding(
                node.v<WindowPadding>(a[0]), double.tryParse(a[1]));
          } else
            return null;
        }
    }
  }, mode: XmlLayout.Text);

  XmlLayout.reg(Container, (node, key) {
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
      clipBehavior: node.s<Clip>("clipBehavior", Clip.none),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ui.WindowPadding, (node, key) {
    switch (node.text) {
      case 'zero':
        return ui.WindowPadding.zero;
      default:
        return null;
    }
  }, mode: XmlLayout.Text);
}


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../xml_layout.dart';
import '../register.dart';
import 'colors.dart' as colors;
import 'drag.dart' as drag;
import 'rect.dart' as rect;
import 'text.dart' as text;

Register reg = Register(() {
  colors.reg();
  drag.reg();
  rect.reg();
  text.reg();

  XmlLayout.reg(Scaffold, (node, key) {
    return Scaffold(
      key: key,
      appBar: node.s<PreferredSizeWidget>("appBar"),
      body: node.s<Widget>("body"),
      floatingActionButton: node.s<Widget>("floatingActionButton"),
      floatingActionButtonLocation: node.s<FloatingActionButtonLocation>("floatingActionButtonLocation"),
      floatingActionButtonAnimator: node.s<FloatingActionButtonAnimator>("floatingActionButtonAnimator"),
      persistentFooterButtons: node.arr<Widget>("persistentFooterButtons"),
      drawer: node.s<Widget>("drawer"),
      endDrawer: node.s<Widget>("endDrawer"),
      bottomNavigationBar: node.s<Widget>("bottomNavigationBar"),
      bottomSheet: node.s<Widget>("bottomSheet"),
      backgroundColor: node.s<Color>("backgroundColor"),
      resizeToAvoidBottomPadding: node.s<bool>("resizeToAvoidBottomPadding"),
      resizeToAvoidBottomInset: node.s<bool>("resizeToAvoidBottomInset"),
      primary: node.s<bool>("primary", true),
      drawerDragStartBehavior: node.s<DragStartBehavior>("drawerDragStartBehavior", DragStartBehavior.start),
      extendBody: node.s<bool>("extendBody", false),
      extendBodyBehindAppBar: node.s<bool>("extendBodyBehindAppBar", false),
      drawerScrimColor: node.s<Color>("drawerScrimColor"),
      drawerEdgeDragWidth: node.s<double>("drawerEdgeDragWidth"),
      drawerEnableOpenDragGesture: node.s<bool>("drawerEnableOpenDragGesture", true),
      endDrawerEnableOpenDragGesture: node.s<bool>("endDrawerEnableOpenDragGesture", true),
    );
  }, mode: XmlLayout.Element);

  XmlLayout.reg(PreferredSize, (node, key) {
    return PreferredSize(
      child: node.child<Widget>(),
      preferredSize: node.s<Size>("PreferredSize"),
    );
  });
  XmlLayout.reg(FloatingActionButtonLocation, (node, key) {
    switch (node.text) {
      case 'endFloat': return FloatingActionButtonLocation.endFloat;
      case 'centerFloat': return FloatingActionButtonLocation.centerFloat;
      case 'endDocked': return FloatingActionButtonLocation.endDocked;
      case 'centerDocked': return FloatingActionButtonLocation.centerDocked;
      case 'startTop': return FloatingActionButtonLocation.startTop;
      case 'miniStartTop': return FloatingActionButtonLocation.miniStartTop;
      case 'endTop': return FloatingActionButtonLocation.endTop;
      default: return null;
    }
  }, mode: XmlLayout.Text);
  XmlLayout.reg(FloatingActionButtonAnimator, (node, key) {
    switch (node.text) {
      case 'scaling': return FloatingActionButtonAnimator.scaling;
      default: return null;
    }
  }, mode: XmlLayout.Text);

  XmlLayout.reg(AppBar, (node, key) {
    return AppBar(
      key: key,
      leading: node.s<Widget>("leading"),
      automaticallyImplyLeading: node.s<bool>("automaticallyImplyLeading", true),
      title: node.s<Widget>("title"),
      actions: node.arr<Widget>("actions"),
      flexibleSpace: node.s<Widget>("flexibleSpace"),
      bottom: node.s<PreferredSizeWidget>("bottom"),
      elevation: node.s<double>("elevation"),
      shape: node.s<ShapeBorder>("shape"),
      backgroundColor: node.s<Color>("backgroundColor"),
      brightness: node.s<Brightness>("brightness"),
      iconTheme: node.s<IconThemeData>("iconTheme"),
      actionsIconTheme: node.s<IconThemeData>("actionsIconTheme"),
      textTheme: node.s<TextTheme>("textTheme"),
    );
  });
});
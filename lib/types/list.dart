import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:xml_layout/register.dart';

import '../xml_layout.dart';

import 'drag.dart' as drag;

Register reg = Register(() {
  drag.reg();

  XmlLayout.reg(ListTile, (node, key) {
    return ListTile(
      key: key,
      leading: node.s<Widget>("leading"),
      title: node.s<Widget>("title"),
      subtitle: node.s<Widget>("subtitle"),
      trailing: node.s<Widget>("trailing"),
      isThreeLine: node.s<bool>("isThreeLine", false),
      dense: node.s<bool>("dense"),
      contentPadding: node.s<EdgeInsetsGeometry>("contentPadding"),
      enabled: node.s<bool>("enabled", true),
      selected: node.s<bool>("selected", false),
      onTap: node.s<GestureTapCallback>("onTap"),
      onLongPress: node.s<GestureLongPressCallback>("onLongPress"),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg(CustomScrollView, (node, key) {
    return CustomScrollView(
        key: key,
        scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
        reverse: node.s<bool>("reverse", false),
        controller: node.s<ScrollController>("controller"),
        primary: node.s<bool>("primary"),
        physics: node.s<ScrollPhysics>("physics"),
        shrinkWrap: node.s<bool>("shrinkWrap", false),
        center: node.s<Key>("center"),
        anchor: node.s<double>("anchor", 0),
        cacheExtent: node.s<double>("cacheExtent"),
        slivers: node.children<Widget>(),
        semanticChildCount: node.s<int>("semanticChildCount"),
        dragStartBehavior: node.s<DragStartBehavior>(
            "dragStartBehavior", DragStartBehavior.start));
  }, mode: XmlLayout.Element);
  XmlLayout.reg(ListView, (node, key) {
    return ListView(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      padding: node.s<EdgeInsetsGeometry>("padding"),
      itemExtent: node.s<double>("itemExtent"),
      addAutomaticKeepAlives: node.s<bool>("addAutomaticKeepAlives", true),
      addRepaintBoundaries: node.s<bool>("addRepaintBoundaries", true),
      addSemanticIndexes: node.s<bool>("addSemanticIndexes", true),
      cacheExtent: node.s<double>("cacheExtent"),
      semanticChildCount: node.s<int>("semanticChildCount"),
      dragStartBehavior: node.s<DragStartBehavior>(
          "dragStartBehavior", DragStartBehavior.start),
      keyboardDismissBehavior: node.s<ScrollViewKeyboardDismissBehavior>(
          "keyboardDismissBehavior", ScrollViewKeyboardDismissBehavior.manual),
      children: node.children<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("ListView.builder", (node, key) {
    return ListView.builder(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      padding: node.s<EdgeInsetsGeometry>("padding"),
      itemExtent: node.s<double>("itemExtent"),
      addAutomaticKeepAlives: node.s<bool>("addAutomaticKeepAlives", true),
      addRepaintBoundaries: node.s<bool>("addRepaintBoundaries", true),
      addSemanticIndexes: node.s<bool>("addSemanticIndexes", true),
      cacheExtent: node.s<double>("cacheExtent"),
      semanticChildCount: node.s<int>("semanticChildCount"),
      dragStartBehavior: node.s<DragStartBehavior>(
          "dragStartBehavior", DragStartBehavior.start),
      itemBuilder: node.s<IndexedWidgetBuilder>("itemBuilder"),
      itemCount: node.s<int>("itemCount"),
    );
  });
  XmlLayout.reg("ListView.separated", (node, key) {
    return ListView.separated(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      padding: node.s<EdgeInsetsGeometry>("padding"),
      addAutomaticKeepAlives: node.s<bool>("addAutomaticKeepAlives", true),
      addRepaintBoundaries: node.s<bool>("addRepaintBoundaries", true),
      addSemanticIndexes: node.s<bool>("addSemanticIndexes", true),
      cacheExtent: node.s<double>("cacheExtent"),
      itemBuilder: node.s<IndexedWidgetBuilder>("itemBuilder"),
      separatorBuilder: node.s<IndexedWidgetBuilder>("separatorBuilder"),
      itemCount: node.s<int>("itemCount"),
    );
  });
  XmlLayout.reg("ListView.custom", (node, key) {
    return ListView.custom(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      padding: node.s<EdgeInsetsGeometry>("padding"),
      itemExtent: node.s<double>("itemExtent"),
      cacheExtent: node.s<double>("cacheExtent"),
      semanticChildCount: node.s<int>("semanticChildCount"),
      childrenDelegate: node.s<SliverChildDelegate>("childrenDelegate"),
    );
  });
  XmlLayout.reg(GridView, (node, key) {
    return GridView(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      addAutomaticKeepAlives: node.s<bool>("addAutomaticKeepAlives", true),
      addRepaintBoundaries: node.s<bool>("addRepaintBoundaries", true),
      addSemanticIndexes: node.s<bool>("addSemanticIndexes", true),
      cacheExtent: node.s<double>("cacheExtent"),
      semanticChildCount: node.s<int>("semanticChildCount"),
      gridDelegate: node.s<SliverGridDelegate>("gridDelegate"),
      children: node.children<Widget>(),
    );
  }, mode: XmlLayout.Element);
  XmlLayout.reg("GridView.builder", (node, key) {
    return GridView.builder(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      addAutomaticKeepAlives: node.s<bool>("addAutomaticKeepAlives", true),
      addRepaintBoundaries: node.s<bool>("addRepaintBoundaries", true),
      addSemanticIndexes: node.s<bool>("addSemanticIndexes", true),
      cacheExtent: node.s<double>("cacheExtent"),
      semanticChildCount: node.s<int>("semanticChildCount"),
      gridDelegate: node.s<SliverGridDelegate>("gridDelegate"),
      itemCount: node.s<int>("itemCount"),
      itemBuilder: node.s<IndexedWidgetBuilder>("itemBuilder"),
    );
  });
  XmlLayout.reg("GridView.custom", (node, key) {
    return GridView.custom(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      cacheExtent: node.s<double>("cacheExtent"),
      semanticChildCount: node.s<int>("semanticChildCount"),
      dragStartBehavior: node.s<DragStartBehavior>(
          "dragStartBehavior", DragStartBehavior.start),
      gridDelegate: node.s<SliverGridDelegate>("gridDelegate"),
      childrenDelegate: node.s<SliverChildDelegate>("childrenDelegate"),
    );
  });
  XmlLayout.reg("GridView.count", (node, key) {
    return GridView.count(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      addAutomaticKeepAlives: node.s<bool>("addAutomaticKeepAlives", true),
      addRepaintBoundaries: node.s<bool>("addRepaintBoundaries", true),
      addSemanticIndexes: node.s<bool>("addSemanticIndexes", true),
      cacheExtent: node.s<double>("cacheExtent"),
      semanticChildCount: node.s<int>("semanticChildCount"),
      dragStartBehavior: node.s<DragStartBehavior>(
          "dragStartBehavior", DragStartBehavior.start),
      crossAxisCount: node.s<int>("crossAxisCount"),
      mainAxisSpacing: node.s<double>("mainAxisSpacing", 0),
      crossAxisSpacing: node.s<double>("crossAxisSpacing", 0),
      childAspectRatio: node.s<double>("childAspectRatio", 1),
      children: node.children<Widget>(),
    );
  });
  XmlLayout.reg("GridView.extent", (node, key) {
    return GridView.extent(
      key: key,
      scrollDirection: node.s<Axis>("scrollDirection", Axis.vertical),
      reverse: node.s<bool>("reverse", false),
      controller: node.s<ScrollController>("controller"),
      primary: node.s<bool>("primary"),
      physics: node.s<ScrollPhysics>("physics"),
      shrinkWrap: node.s<bool>("shrinkWrap", false),
      addAutomaticKeepAlives: node.s<bool>("addAutomaticKeepAlives", true),
      addRepaintBoundaries: node.s<bool>("addRepaintBoundaries", true),
      addSemanticIndexes: node.s<bool>("addSemanticIndexes", true),
      semanticChildCount: node.s<int>("semanticChildCount"),
      dragStartBehavior: node.s<DragStartBehavior>(
          "dragStartBehavior", DragStartBehavior.start),
      mainAxisSpacing: node.s<double>("mainAxisSpacing", 0),
      crossAxisSpacing: node.s<double>("crossAxisSpacing", 0),
      childAspectRatio: node.s<double>("childAspectRatio", 1),
      maxCrossAxisExtent: node.s<double>("maxCrossAxisExtent"),
      children: node.children<Widget>(),
    );
  });
});

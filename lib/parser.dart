
import 'dart:convert';

import 'status.dart';

List<int> _dots(String p) {
  List<int> dots = [];
  int deep = 0, deep1 = 0, deep2 = 0;
  bool sentence = false;
  for (int i = 0, t = p.length; i < t; ++i) {
    String ch = p[i];
    if (ch == r"\") {
      i++;
    } else if (ch == "\"") {
      if (!sentence) {
        sentence = true;
      } else {
        sentence = false;
      }
    } else if (ch == "(") {
      if (!sentence) {
        deep++;
      }
    } else if (ch == ")") {
      if (!sentence) {
        deep--;
      }
    } else if (ch == "[") {
      if (!sentence) {
        deep1++;
      }
    } else if (ch == "]") {
      if (!sentence) {
        deep1--;
      }
    } else if (ch == "{") {
      if (!sentence) {
        deep2++;
      }
    } else if (ch == "}") {
      if (!sentence) {
        deep2--;
      }
    } else if (ch == ",") {
      if (!sentence && deep == 0 && deep1 == 0 && deep2 == 0) {
        dots.add(i);
      }
    }
  }
  return dots;
}

RegExp _regExp = RegExp(r"^(\w*)\(([^`]*)\)$");

class MethodNode {
  late String name;
  late List arguments;
  MethodNode._();

  static MethodNode defaultNode = MethodNode._()
    ..name = ''
    .. arguments = [];

  static MethodNode? parse(String str, Status status) {
    var matches = _regExp.allMatches(str);
    if (matches.length > 0) {
      var match = matches.first;
      MethodNode method = MethodNode._();
      method.name = match.group(1)!;
      method.arguments = [];
      String param = match.group(2)!.trim();
      List<int> dots = _dots(param);

      void insertParam(String param) {
        method.arguments.add(status.execute(param));
      }
      if (dots.length > 0) {
        int off = 0;
        dots.forEach((i) {
          insertParam(param.substring(off, i).trim());
          off = i + 1;
        });
        insertParam(param.substring(off).trim());
      } else if (param.isNotEmpty) {
        insertParam(param.trim());
      }
      return method;
    } else
      return null;
  }

  int get length => arguments.length;
  dynamic operator [](int idx) => arguments[idx];
  List<T> map<T>(T Function(dynamic) fn) => arguments.map(fn).toList();

}


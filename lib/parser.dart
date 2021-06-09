
import 'dart:convert';

import 'status.dart';

typedef MethodHandler = dynamic Function(MethodNode);
typedef ValueGetter = dynamic Function(String path);

Map<String, MethodHandler> _methods = {
  "isEmpty": (method) {
    return method[0].isEmpty;
  },
  "isNotEmpty": (method) {
    return method[0].isNotEmpty;
  },
  "equal": (method) {
    if (method.length > 0) {
      var last = method[0];
      for (int i = 1, t = method.length; i < t; ++i) {
        if (last != method[i]) return false;
      }
    }
    return true;
  },
  "mod": (method) {
    return method[0] % method[1];
  },
  "div": (method) {
    return method[0] / method[1];
  },
};

void registerMethod(String name, MethodHandler handler) {
  _methods[name] = handler;
}

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

RegExp _matchRegExp1 = RegExp(r"^\$([\w_]+)$");
RegExp _matchRegExp2 = RegExp(r"^\$\{([^\}]+)\}$");
RegExp _regExp = RegExp(r"^(\w*)\(([^`]*)\)$");

class MethodNode {
  String name;
  List arguments;
  MethodNode._();

  factory MethodNode.parse(String str, Status status) {
    var matches = _regExp.allMatches(str);
    if (matches.length > 0) {
      var match = matches.first;
      MethodNode method = MethodNode._();
      method.name = match.group(1);
      method.arguments = [];
      String param = match.group(2).trim();
      List<int> dots = _dots(param);

      void insertParam(String param) {
        if (param.indexOf("(") > 0) {
          MethodNode m = MethodNode.parse(param, status);
          if (_methods.containsKey(m.name)) {
            var handler = _methods[m.name];
            method.arguments.add(handler(m));
          } else {
            method.arguments.add(null);
          }
        } else {
          if (param.startsWith("\$")) {
            Match regExp = _matchRegExp1.firstMatch(param);
            if (regExp == null) {
              regExp = _matchRegExp2.firstMatch(param);
            }

            if (regExp != null) {
              method.arguments.add(status.get(regExp.group(1)));
            } else {
              method.arguments.add(null);
            }
          } else {
            method.arguments.add(jsonDecode(param));
          }
        }
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
  List<T> map<T>(T Function(dynamic) fn) => arguments.map(fn);

  dynamic execute() {
    if (_methods.containsKey(name)) {
      return _methods[name](this);
    } else {
      return null;
    }
  }

  static dynamic inlineParse(String str, Status status) {
    String param = str.trim();
    if (param.indexOf("(") > 0) {
      MethodNode m = MethodNode.parse(param, status);
      if (_methods.containsKey(m.name)) {
        var handler = _methods[m.name];
        return handler(m);
      } else {
        return null;
      }
    } else {
      if (param.startsWith("\$")) {
        Match regExp = _matchRegExp1.firstMatch(param);
        if (regExp == null) {
          regExp = _matchRegExp2.firstMatch(param);
        }

        if (regExp != null) {
          return status.get(regExp.group(1));
        } else {
          return null;
        }
      } else {
        return param;
      }
    }
  }
}


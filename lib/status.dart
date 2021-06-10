
import 'dart:collection';
import 'dart:convert';
import 'parser.dart';


typedef MethodHandler = dynamic Function(MethodNode);

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

_getPath(dynamic tar, List path, int offset) {
  if (offset >= path.length) {
    return tar;
  } else {
    dynamic seg = path[offset];
    if (tar is Map || tar is MapMixin) {
      var sub = seg is String ? tar[seg] : null;
      if (sub == null) return null;
      return _getPath(sub, path, offset + 1);
    } else if (tar is List || tar is ListMixin) {
      if (seg is int) {
        var sub = tar[seg];
        if (sub == null) return null;
        return _getPath(sub, path, offset + 1);
      } else
        return null;
    }
  }
}

RegExp _matchRegExp1 = RegExp(r"^\$([\w_]+)$");
RegExp _matchRegExp2 = RegExp(r"^\$\{([^\}]+)\}$");

class Status {
  Map<String, dynamic> data;

  Status _parent;
  Status get parent => _parent;

  Status(this.data);

  Status child(Map<String, dynamic> data) => Status(data).._parent = this;

  dynamic get(String path) {
    RegExp exp = RegExp(r"^(\w+)((\[[^\]]+\])*)$");
    RegExp bExp = RegExp(r"\[([^\]]+)\]");
    List<String> arr = path.split(".");
    List segs = [];
    for (String seg in arr) {
      RegExpMatch match = exp.firstMatch(seg);
      if (match == null) return null;
      String name = match.group(1);
      String property = match.group(2);
      segs.add(name);
      if (property.length > 0) {
        var matches = bExp.allMatches(property);
        for (Match match in matches) {
          segs.add(jsonDecode(match.group(1)));
        }
      }
    }

    dynamic ret = _getPath(data, segs, 0);
    if (ret == null) {
      var parent = _parent;
      while (parent != null) {
        ret = _getPath(parent.data, segs, 0);
        if (ret != null) break;
        parent = parent._parent;
      }
    }
    return ret;
  }

  dynamic execute(String text) {
    String param = text.trim();
    if (param.indexOf("(") > 0) {
      MethodNode m = MethodNode.parse(param, this);
      dynamic func = get(m.name);
      if (func is Function) {
        return Function.apply(func, m.arguments);
      } else if (_methods.containsKey(m.name)) {
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
          return get(regExp.group(1));
        } else {
          return null;
        }
      } else {
        try {
          return jsonDecode(param);
        } catch (e) {
          return param;
        }
      }
    }
  }
}
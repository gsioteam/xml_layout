
import 'dart:collection';
import 'dart:convert';
import 'parser.dart';

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
    return MethodNode.inlineParse(text, this);
  }
}
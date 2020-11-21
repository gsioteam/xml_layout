
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

class MethodNode {
  String name;
  List<String> arguments;
  MethodNode._();

  factory MethodNode.parse(String str) {
    RegExp exp = RegExp(r"^(\w*)\(([^$]*)\)$");
    var matches = exp.allMatches(str);
    if (matches.length > 0) {
      var match = matches.first;
      MethodNode method = MethodNode._();
      method.name = match.group(1);
      method.arguments = [];
      String param = match.group(2).trim();
      List<int> dots = _dots(param);
      if (dots.length > 0) {
        int off = 0;
        dots.forEach((i) {
          method.arguments.add(param.substring(off, i).trim());
          off = i + 1;
        });
        method.arguments.add(param.substring(off).trim());
      } else if (param.isNotEmpty) {
        method.arguments.add(param);
      }
      return method;
    } else
      return null;
  }

  int get length => arguments.length;
  String operator [](int idx) => arguments[idx];
  List<T> map<T>(T Function(String) fn) => arguments.map(fn);
}

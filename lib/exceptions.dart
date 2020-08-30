library xml_layout;

class TemplateException implements Exception {
  String message;

  TemplateException([this.message]);
}

class NotWidgetException implements Exception {}

class InvalidateParametersException implements Exception {
  Type type;
  int count;

  InvalidateParametersException(this.type, this.count);

  @override
  String toString() {
    return "InvalidateParametersException: $type with $count parameters";
  }
}

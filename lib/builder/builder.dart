
import 'dart:async';

import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:dart_style/dart_style.dart';

/**
 * Build to a [.xml_layout.dart] file
 */
class XmlLayoutBuilder extends Builder {
  final BuilderOptions options;
  Map<ClassElement, List<String>> _processed = Map();
  List<String> imports = List();
  Map<DartType, DartType> _convertTypes = Map();

  static Map<Pattern, String> _inputConvert = {};

  XmlLayoutBuilder(this.options);

  DartType convertType(DartType dartType) {
    if (_convertTypes.containsKey(dartType)) {
      dartType = _convertTypes[dartType];
    }
    return dartType;
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    imports.add("package:xml_layout/xml_layout.dart");
    imports.add("package:xml_layout/register.dart");
    imports.add("dart:convert");
    var library = await buildStep.inputLibrary;
    String entryName = options.config["entry_name"];
    String collectionsName = options.config["collections_name"];
    String convertsName = options.config["coverts_name"];
    String importsName = options.config["imports_name"];
    String convertName = options.config["convert_types"];
    for (var element in library.topLevelElements) {
      if (element.kind == ElementKind.TOP_LEVEL_VARIABLE) {
        var topLevelElement = element as TopLevelVariableElement;
        if (topLevelElement.type?.isDartCoreList == true) {
          if (topLevelElement.name == entryName) {
            var types = topLevelElement.computeConstantValue();
            for (var type in types.toListValue()) {
              _processDartType(type.toTypeValue());
            }
          } else if (topLevelElement.name == convertName) {
            var types = topLevelElement.computeConstantValue();
            types.toMapValue().forEach((key, value) {
              _convertTypes[key.toTypeValue()] = value.toTypeValue();
            });
          } else if (topLevelElement.name == collectionsName) {
            var types = topLevelElement.computeConstantValue();
            for (var type in types.toListValue()) {
              _processCollectionType(type);
            }
          } else if (topLevelElement.name == importsName) {
            var importsList = topLevelElement.computeConstantValue();
            for (var importUri in importsList.toListValue()) {
              String str = importUri.toStringValue();
              if (!imports.contains(str)) {
                imports.add(str);
              }
            }
          }
        }
        if (topLevelElement.type?.isDartCoreMap == true && topLevelElement.name == convertsName) {
          var converts = topLevelElement.computeConstantValue();
          converts.toMapValue().forEach((key, value) {
            print("${key} : $value");
            _inputConvert[key.toStringValue()] = value.toStringValue();
          });
        }
      }
    }

    List<String> codes = [];
    imports.forEach((element) {
      codes.add("import '$element';");
    });
    codes.add("Register register = Register(() {");
    codes.addAll(_processed.values.expand<String>((element) => element));
    codes.add("});");

    String output = DartFormatter().format(codes.join('\n'));
    await buildStep.writeAsString(
        buildStep.inputId.changeExtension('.xml_layout.dart'),
        output
    );
  }

  void _processDartType(DartType dartType) {
    if (dartType != null) {
      if (!dartType.isDartCoreIterable &&
          !dartType.isDartCoreMap &&
          !dartType.isDartCoreFunction &&
          !dartType.isDartCoreList &&
          !dartType.isDartAsyncFuture &&
          !dartType.isDartAsyncFutureOr &&
          !dartType.isDartCoreBool &&
          !dartType.isDartCoreDouble &&
          !dartType.isDartCoreInt &&
          !dartType.isDartCoreNull &&
          !dartType.isDartCoreNum &&
          !dartType.isDartCoreSet &&
          !dartType.isDartCoreString &&
          !dartType.isDartCoreSymbol) {
        var element = dartType.element;
        if (element != null && (element.kind == ElementKind.CLASS || element.kind == ElementKind.ENUM)) {
          _processType(element as ClassElement);
        }
      }
    }
  }

  String _transformInputUri(Uri uri) {
    String src = uri.toString();
    for (var pattern in _inputConvert.keys) {
      if (pattern.matchAsPrefix(src) != null) {
        return _inputConvert[pattern];
      }
    }
    return src;
  }

  void _insertSource(Source source) {
    if (source != null) {
      var uri = source.uri;
      if (uri.scheme == 'dart') {
        uri = Uri.parse('${uri.scheme}:${uri.pathSegments.first}');
      }

      String str = _transformInputUri(uri);
      if (!imports.contains(str)) {
        imports.add(str);
      }
    }
  }

  bool _isConstructorInline(ConstructorElement constructorElement, [Set<DartType> caches]) {
    if (constructorElement.name.isEmpty && constructorElement.parameters.length == 0) return false;

    if (caches == null) {
      caches = {};
      caches.add(constructorElement.returnType);
    }

    for (var param in constructorElement.parameters) {
      if (param.isNamed)
        return false;
      var type = param.type;
      if (type.isDartCoreFunction ||
          type.isDartCoreSymbol ||
          type.isDartCoreSet ||
          type.isDartAsyncFutureOr ||
          type.isDartAsyncFuture ||
          type.isDartCoreList ||
          type.isDartCoreMap ||
          type.isDartCoreIterable
      ) return false;
      if (type.isDartCoreString ||
          type.isDartCoreNum ||
          type.isDartCoreInt ||
          type.isDartCoreDouble ||
          type.isDartCoreBool ||
          type.isDartCoreNull
      ) continue;
      if (caches.contains(type)) continue;
      var element = type.element;
      if (element.kind == ElementKind.ENUM) continue;
      else if (element.kind == ElementKind.CLASS) {
        caches.add(type);
        var classElement = element as ClassElement;
        bool hasInline = false;
        for (var con in classElement.constructors) {
          if (_isConstructorInline(con, caches)) {
            hasInline = true;
            break;
          }
        }
        if (hasInline) continue;
        else return false;
      } else {
        return false;
      }

    }
    return true;
  }

  void _processType(ClassElement classElement) {
    if (_processed.containsKey(classElement)) return;
    _insertSource(classElement.source);

    List<String> codes = [];
    _processed[classElement] = codes;
    if (classElement.isEnum) {
      codes.add('XmlLayout.registerEnum(${classElement.name}.values);');
    } else {
      // Process constructors.
      if (!classElement.isAbstract) {
        for (var con in classElement.constructors) {
          if (con.isPublic) {
            if (con.name.isEmpty && con.parameters.length == 0) continue;
            if (_isConstructorInline(con)) {
              List<String> segs = [];
              segs.add('XmlLayout.registerInline(${classElement.name}, "${con.name}", false, (node, method) {');
              if (con.name.isEmpty) {
                segs.add('return ${classElement.name}(');
              } else {
                segs.add('return ${classElement.name}.${con.name}(');
              }
              List<String> argv = [];
              for (int i = 0, t = con.parameters.length; i < t; i++) {
                var param = con.parameters[i];
                var type = convertType(param.type);
                if (type.isDartCoreInt) {
                  String str = 'int.tryParse(method[$i])';
                  if (param.hasDefaultValue) {
                    str += '??${param.defaultValueCode}';
                  }
                  argv.add(str);
                } else if (type.isDartCoreDouble || type.isDartCoreNum) {
                  String str = 'double.tryParse(method[$i])';
                  if (param.hasDefaultValue) {
                    str += '??${param.defaultValueCode}';
                  }
                  argv.add(str);
                } else if (type.isDartCoreString) {
                  argv.add('jsonDecode(method[$i])');
                } else {
                  String str = 'node.v<${type.getDisplayString(withNullability: false)}>(method[$i]';
                  if (param.hasDefaultValue) {
                    str += ',${param.defaultValueCode}';
                  }
                  str += ')';
                  argv.add(str);
                }
              }
              segs.add(argv.join(','));
              segs.add(');');
              segs.add('});');

              codes.add(segs.join('\n'));
            } else {
              String constructorName = con.name.isEmpty ? "${classElement.name}" : "${classElement.name}.${con.name}";
              List<String> segs = [];
              segs.add('XmlLayout.register("$constructorName", (node, key) {');
              segs.add('return $constructorName(');
              List<String> params = [];

              void insertNamedParam(ParameterElement param) {
                var type = convertType(param.type);
                List<String> argv = [];
                argv.add('"${param.name}"');
                if (param.hasDefaultValue) {
                  argv.add(param.defaultValueCode);
                }
                _processDartType(type);
                if (type.element?.kind == ElementKind.GENERIC_FUNCTION_TYPE) {
                  var elem = (type.element as GenericFunctionTypeElement);
                  _insertSource(elem.returnType.element?.source);
                  for (var param in elem.parameters) {
                    _insertSource(param.type.element?.source);
                  }
                }

                if (type.isDartCoreList || type.isDartCoreIterable) {
                  var dartType = convertType((type as ParameterizedType).typeArguments.first);
                  params.add('${param.name}: node.array<${dartType.getDisplayString(withNullability: false)}>(${argv[0]})');
                } else {
                  params.add('${param.name}: node.s<${type.getDisplayString(withNullability: false)}>(${argv.join(',')})');
                }
              }

              void insertIndexParam(ParameterElement param, int index) {
                var type = param.type;
                List<String> argv = [];
                argv.add('"arg:$index"');
                if (param.hasDefaultValue) {
                  argv.add(param.defaultValueCode);
                }
                _processDartType(type);
                if (type.isDartCoreList || type.isDartCoreIterable) {
                  var dartType = (type as ParameterizedType).typeArguments.first;
                  params.insert(index, 'node.array<${dartType.getDisplayString(withNullability: false)}>(${argv[0]})');
                } else {
                  params.insert(index, 'node.s<${type.getDisplayString(withNullability: false)}>(${argv.join(',')})');
                }
              }

              bool hasChild = false;
              List<ParameterElement> indexedParams = [];
              for (var param in con.parameters) {
                if (param.isNamed) {
                  switch (param.name) {
                    case 'key': {
                      params.add('${param.name}: key');
                      break;
                    }
                    case 'child': {
                      hasChild = true;
                      var type = convertType(param.type);
                      _processDartType(type);
                      params.add('${param.name}: node.child<${type.getDisplayString(withNullability: false)}>()');
                      break;
                    }
                    case 'children':
                    case 'slivers': {
                      hasChild = true;
                      var type = convertType(param.type);
                      if (type.isDartCoreList) {
                        String typeName;
                        if (type is ParameterizedType) {
                          typeName = type.typeArguments.first.getDisplayString(withNullability: false);
                        } else {
                          typeName = 'dynamic';
                        }
                        _processDartType(type);
                        params.add('${param.name}: node.children<$typeName>()');
                      } else {
                        insertNamedParam(param);
                      }
                      break;
                    }
                    default: {
                      insertNamedParam(param);
                      break;
                    }
                  }
                } else {
                  indexedParams.add(param);
                }
              }

              if (indexedParams.length == 1) {
                if (hasChild) {
                  insertIndexParam(indexedParams.first, 0);
                } else {
                  var param = indexedParams.first;
                  List<String> argv = [];
                  argv.add('"arg:0"');
                  if (param.hasDefaultValue) {
                    argv.add(param.defaultValueCode);
                  }
                  var type = convertType(param.type);
                  String typeName = type.getDisplayString(withNullability: false);
                  String child;
                  if (type.isDartCoreString ||
                      type.isDartCoreInt ||
                      type.isDartCoreDouble ||
                      type.isDartCoreBool
                  ) {
                    child = 'node.t<$typeName>()';
                  } else {
                    child = 'node.child<$typeName>()';
                    _insertSource(param.type?.element?.source);
                  }
                  params.insert(0, 'node.s<$typeName>(${argv.join(',')}) ?? $child');
                }
              } else {
                for (var index = 0, t = indexedParams.length; index < t; ++index) {
                  insertIndexParam(indexedParams[index], index);
                }
              }

              segs.add(params.join(','));
              segs.add(');');
              segs.add('});');
              codes.add(segs.join('\n'));
            }
          }
        }
      }

      // Process static fields.
      for (var field in classElement.fields) {
        if (field.isStatic && field.isPublic && field.type == classElement.thisType) {
          List<String> segs = [];
          segs.add('XmlLayout.registerInline(${classElement.name}, "${field.name}", true, (node, method) {');
          segs.add("return ${classElement.name}.${field.name};");
          segs.add('});');

          codes.add(segs.join('\n'));
        }
      }
    }
  }

  bool _isSubTypeOf(InterfaceType type, InterfaceType targetType) {
    if (type == targetType) return true;
    for (var supperType in type.allSupertypes) {
      var ret = _isSubTypeOf(supperType, targetType);
      if (ret) return true;
    }
    return false;
  }

  void _processCollectionType(DartObject dartObject) {
    DartType dartType = dartObject.getField("collectionType").toTypeValue();
    DartType targetType = dartObject.getField("targetType").toTypeValue();
    ClassElement classElement = dartType.element as ClassElement;
    if (_processed.containsKey(classElement)) return;
    _insertSource(classElement.source);

    List<String> codes = [];
    _processed[classElement] = codes;

    for (var field in classElement.fields) {
      if (field.isStatic && field.isPublic) {
        var type = field.type;
        if (type is InterfaceType && targetType != null && !_isSubTypeOf(type, targetType)) {
          continue;
        }
        _insertSource(type.element?.source);
        if (type is ParameterizedType) {
          for (var arg in type.typeArguments) {
            _insertSource(arg.element?.source);
          }
        }
        List<String> segs = [];
        segs.add('XmlLayout.registerInline(${targetType.getDisplayString(withNullability: false)}, "${field.name}", true, (node, method) {');
        segs.add("return ${classElement.name}.${field.name};");
        segs.add('});');

        codes.add(segs.join('\n'));
      }
    }
  }

  String _removeGeneric(DartType type) {
    String name = type.getDisplayString(withNullability: false);
    int index = name.indexOf('<');
    if (index >= 0) {
      return name.substring(0, index);
    }
    return name;
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.xml_layout.dart']
  };
}

XmlLayoutBuilder builderFactory(BuilderOptions options) {
  return XmlLayoutBuilder(options);
}
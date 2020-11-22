# xml_layout

XML layout for flutter. Layout your UI via xml at runtime. and support extending any customer widget.

## Getting Started

write xml layout file like:

*xml*
```xml
<Text mainAxisAlignment="center">
    <for count="6">
        <Text>$item, You have pushed the button this many times:</Text>
    </for>
    <Text id="text-id">$counter</Text>
        <attr:style>
            <TextStyle color="red"/>
        </attr:style>
    </Text>
</Column>
```

*dart*
```dart
XMLLayout(
    temp: snapshot.data,
    objects: {
        "counter": _counter
    },
)
``` 

In this case

`$counter` for passing argument to the layout.

`id` attribute for selecting the widget or state.

```
XMLLayoutState state = ...;
// find the key of the Text 
GlobalKey key = state.find('text-id');
```

## Support Customer Widget

```dart
// Register a class
XMLLayout.reg(MyClass, (node, key) {
    return MyClass(
        key: key,
        child: node.child<Widget>(),
        width: node.s<double>("width"),
        height: node.s<double>("height"),
    );
});

// Register a Enum
XMLLayout.registerEnum(MyEnum.values);
```

`node.s<T>("name")`, `node.attribute<T>("name")` convert subnode to target type

`node.t<T>()`, `node.convert<T>()` convert this node to target type

`node.v<T>("value")`, `node.value<T>("value")` convert text to target type

## Builder

You can write a script to generate the constructor code. 
In the example `test.dart` is the builder script.

#### Builder options:

- `entry_name`
    - default: `types`
    - type: `List<Type>`
    - description: types in this list which will be processed.
- `collections_name`
    - default: `collections`
    - type: `List<Collection>`
    - description: Collection type is used to process the collection class, such as: `Colors` 
    and `Icons`.
     
ps: `Colors` and `Icons` is preprocessed just import it via:
    
```dart
import 'package:xml_layout/types/colors.dart' as colors;
import 'package:xml_layout/types/icons.dart' as icons;

// ...

colors.register();
icons.register();
```
 
- `coverts_name`
    - default: `converts`
    - type: `Map<String, String>`
    - description: Every import uri will be test by the key value pair in this variable.
    if a import source uri is start with the key then it will be convert to the value. 
- `imports_name`
    - default: `imports`
    - type: `List<String>`
    - description: Extension import uris which will be write to the generated code.
    
#### Example

lib/test.dart
```dart
import 'package:flutter/material.dart';

const List<Type> types = [
  Text,
];
```

build.yaml
```yaml
targets:
  $default:
    builders:
      xml_layout:
        generate_for:
          - lib/test.dart
```

Create the files above, then just run `flutter pub run build_runner build`.
and you will get the generated code in `lib/test.xml_layout.dart`.

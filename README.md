# xml_layout

XML layout for flutter. Layout your UI via xml at runtime. and support extending any customer widget. Here is a [preview](https://gsioteam.github.io/xml_layout_preview/) website.

## Getting Started

write xml layout file like:

*xml*
```xml
<Text mainAxisAlignment="center">
    <for count="6">
        <Text>$item, You have pushed the button this many times:</Text>
    </for>
    <Text id="text-id">
        <attr:style>
            <TextStyle color="red"/>
        </attr:style>
        $counter
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

## Registers

- `register` 
    - description: Register a constructor. It could convert a xml element to target object.

```dart
/**
 * Register a constructor
 * 
 * xml:
 * <MyClass width="10" height="10" />
 * 
 */
XMLLayout.register('MyClass', (node, key) {
    return MyClass(
        key: key,
        child: node.child<Widget>(),
        width: node.s<double>("width"),
        height: node.s<double>("height"),
    );
});
```

- `registerEnum` 
    - description: A shortcat to register a enum class. It could convert a attribute to the enum.
 
 ```dart
/**
 * Register a enum type
 * 
 * xml:
 * <Text textAlign="center">str</Text>
 */
XMLLayout.registerEnum(TextAlign.values);
 ```

 - `registerInline(Type type, String name, bool field, InlineItemConstructor constructor)` 
    - description: Register a constructor which could convert a attribute to target type.
    - arguments: 
        - `field` this constructor is for a static field or a constructor.

```dart
/**
 * <Text fontWeight="w200">str</Text>
 */
XmlLayout.registerInline(FontWeight, "w200", true, (node, method) {
  return FontWeight.w200;
});

/**
 * <Text textHeightBehavior="fromEncoded(20)">str</Text>
 */
XmlLayout.registerInline(TextHeightBehavior, "fromEncoded", false,
      (node, method) {
  return TextHeightBehavior.fromEncoded(int.tryParse(method[0]));
});
```

`node.s<T>("name")`, `node.attribute<T>("name")` convert subnode to target type

`node.t<T>()`, `node.convert<T>()` convert this node to target type

`node.v<T>("value")`, `node.value<T>("value")` convert text to target type

### Widget Builder 

```xml
<ListView.separated itemCount="$itemCount">
    <attr:itemBuilder>
        <Function returnType="Widget">
            <!-- get arguments of function via args -->
            <SetArgument return="index" argument="${args[1]}"/>
            <Call function="$getItem" return="itemData">
                <!-- pass argument to getItem function -->
                <Argument value="$index"/>
            </Call>
            <!-- The last element of Function tag would be the final result -->
            <Text>${itemData.title}</Text>
        </Function>
    </attr:itemBuilder>
</ListView.separated>
```

### Script

```xml
<Function>
    <Script>
        set("index", ${args[1]})
        set("itemData", getItem($index))
    </Script>
    <!-- same as -->
    <SetArgument return="index" argument="${args[1]}"/>
    <Call function="$getItem" return="itemData">
        <Argument value="$index"/>
    </Call>
    <!-- end(same as) -->

    <Text>${itemData.title}</Text>
</Function>
```

### Method

`Method` could be registerd via `XmlLayout.registerInlineMethod`, and 
can be used in a Xml attribute or Script tag.

Default methods:

- `isEmpty(a)` => a.isEmpty()
- `isNotEmpty(a)` => a.isNotEmpty()
- `equal(a, b, ...)` => a == b ...
- `net(a, b)` => a != b
- `mod(a, b)` => a % b
- `div(a, b)` => a / b
- `set(name, a)` => env[name] = a
- `not(a)` => !a
- `lt(a, b)` => a < b
- `nlt(a, b)` => a >= b
- `gt(a, b)` => a > b
- `ngt(a, b)` => a <= b
- `plus(a, b, ...)` => a + b ...
- `minus(a, b, ...)` => a - b ...
- `multiply(a, b, ...)` => a * b ...
- `divide(a, b, ...)` => a / b ...

### Control Flow 

A util to control the rendering logic. like:

```xml
<for count="$counter">
    <Text>$item, You have pushed the button this many times:</Text>
    <if candidate="equal(1, mod($item, 2))">
        <Text>Test text</Text>
    </if>
</for>
```

- `if` tag is a if control flow.
    - attributes:
        - `candidate` a Boolean value, if true the children would be rendered, otherwise not be rendered.
- `else` tag is a else control flow, could be used after `if` or another `else` tag.
    - attributes:
        - `candidate` same as `if` tag.
- `for` tag is a loop control flow.
    - attributes: 
        - `array` a List value, iterates over array elements, each element for children one time.
        - `count` a Integer value, iterates children the value times. It is mutually exclusive with the `array` attribute.
        - `item` a String value, the name of each element, default is `item`.
        - `index` a String value, the name of the index of element, default is `index`.

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
And you will get the generated code in `lib/test.xml_layout.dart`.

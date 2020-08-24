# xml_layout

XML layout for flutter. You can layout your UI via xml at runtime. and support extending any customer widget.

## Getting Started

write xml layout file like:

*xml*
```xml
<Column mainAxisAlignment="center">
    <Text text="You have pushed the button this many times:"/>
    <Text text="$counter" id="text-id">
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

`id` attribute for select the widget or state.

```
XMLLayoutState state = ...;
// find the key of the Text 
GlobalKey key = state.find('text-id');
```

## Support Widget

All support widget are write in `types/*.dart` files. Find the class name to check if supported.

## Support Customer Widget

```dart
// Register a class
XMLLayout.reg(MyClass, (node, key) {
    return MyClass(
        key: key,
        child: node.child<Widget>(),
        width: node.s<double>("width"),
        width: node.s<double>("width"),
    );
});

// Register a Enum
XMLLayout.regEnum(MyEnum.values);
```

`node.s<T>("name")` convert subnode to target type
`node.t<T>()` convert this node to target type
`node.v<T>("value")` convert text to target type


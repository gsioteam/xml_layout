import 'package:flutter/material.dart';
import 'package:xml_layout/xml_layout.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml_layout/types/all.dart' as all_type;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    all_type.reg();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<String> _loadLayout(String path) {
  return rootBundle.loadString(path);
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
          children: ListTile.divideTiles(tiles: [
        ListTile(
          title: Text("LayoutExample"),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => _LayoutExample())),
        ),
        ListTile(
          title: Text("GridExample"),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => _GridExample())),
        )
      ], context: context, color: Colors.black12)
              .toList()),
    );
  }
}

class _LayoutExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LayoutExampleState();
}

class _LayoutExampleState extends State<_LayoutExample> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Layout Example"),
      ),
      body: Center(
        child: FutureBuilder<String>(
            future: _loadLayout("assets/layout.xml"),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return XmlLayout(
                  template: snapshot.data,
                  objects: {"counter": _counter},
                );
              }
              return Container();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class _GridExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _loadLayout("assets/grid.xml"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return XmlLayout(
              template: snapshot.data,
              objects: {
                "map": {
                  "pictures": [
                    "https://homepages.cae.wisc.edu/~ece533/images/baboon.png",
                    "https://homepages.cae.wisc.edu/~ece533/images/arctichare.png",
                    "https://homepages.cae.wisc.edu/~ece533/images/airplane.png"
                  ]
                }
              },
            );
          }
          return Container();
        });
  }
}

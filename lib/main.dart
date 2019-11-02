import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Alex Meteo'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> villes = ["Paris", "Bordeaux", "Lille"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      drawer: new Drawer(
        child: new Container(
          color: Colors.blue,
          child: new ListView.builder(
            itemCount: villes.length,
            itemBuilder: (context, i) {
              return new ListTile(
                title: new Text(villes[i]),
                onTap: () {},
              );
            },
          ),
        ),
      ),
      body: Center(),
    );
  }
}

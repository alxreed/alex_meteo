import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String key = "ville";
  List<String> villes = [];

  String villeChoisie;

  @override
  void initState() {
    super.initState();
    obtenir();
  }

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
            itemCount: villes.length + 2,
            itemBuilder: (context, i) {
              if (i == 0) {
                return new DrawerHeader(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      textAvecStyle("Mes villes", fontSize: 22.0),
                      new RaisedButton(
                        onPressed: ajoutVille,
                        child: textAvecStyle("Ajouter une ville",
                            color: Colors.blue),
                        color: Colors.white,
                        elevation: 8.0,
                      )
                    ],
                  ),
                );
              } else if (i == 1) {
                return new ListTile(
                  title: textAvecStyle("Ma ville actuelle"),
                  onTap: () {
                    setState(() {
                      villeChoisie = null;
                      Navigator.pop(context);
                    });
                  },
                );
              } else {
                String ville = villes[i - 2];
                return new ListTile(
                  title: textAvecStyle(ville),
                  onTap: () {
                    setState(() {
                      villeChoisie = ville;
                      Navigator.pop(context);
                    });
                  },
                );
              }
            },
          ),
        ),
      ),
      body: Center(
        child:
            new Text((villeChoisie == null) ? "Ville actuelle" : villeChoisie),
      ),
    );
  }

  Text textAvecStyle(String data,
      {color: Colors.white,
      fontSize: 18.0,
      fontStyle: FontStyle.italic,
      textAlign: TextAlign.center}) {
    return new Text(
      data,
      textAlign: textAlign,
      style:
          new TextStyle(color: color, fontStyle: fontStyle, fontSize: fontSize),
    );
  }

  Future<Null> ajoutVille() async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext buildContext) {
          return new SimpleDialog(
            contentPadding: EdgeInsets.all(20),
            title: textAvecStyle("Ajouter une ville",
                fontSize: 22.0, color: Colors.blue),
            children: <Widget>[
              new TextField(
                decoration: new InputDecoration(
                  labelText: "Ville:",
                ),
                onSubmitted: (String str) {
                  Navigator.pop(buildContext);
                },
              )
            ],
          );
        });
  }

  void obtenir() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> liste = await sharedPreferences.getStringList(key);
    if (liste != null) {
      setState(() {
        villes = liste;
      });
    }
  }
}

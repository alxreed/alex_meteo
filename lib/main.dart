import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

void main() async {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  if (position != null) {
    print(position);
    final latitude = position.latitude;
    final longitude = position.longitude;
    // final Coordinates coordinates = new Coordinates(latitude, longitude);
    // final ville = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    List<Placemark> ville =
        await Geolocator().placemarkFromCoordinates(latitude, longitude);
    if (ville != null) {
      print(ville.first.locality);
      runApp(MyApp(ville.first.locality));
    }
  }
}

class MyApp extends StatelessWidget {
  MyApp(String ville) {
    this.ville = ville;
  }

  String ville;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(ville, title: 'Alex Meteo'),
    );
  }
}

class Home extends StatefulWidget {
  Home(String ville, {Key key, this.title}) : super(key: key) {
    this.villeDeLutilisateur = ville;
  }

  String villeDeLutilisateur;
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
    coordonnees();
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
                  title: textAvecStyle(widget.villeDeLutilisateur),
                  onTap: () {
                    setState(() {
                      villeChoisie = null;
                      coordonnees();
                      Navigator.pop(context);
                    });
                  },
                );
              } else {
                String ville = villes[i - 2];
                return new ListTile(
                  title: textAvecStyle(ville),
                  trailing: new IconButton(
                    icon: new Icon(Icons.delete, color: Colors.white),
                    onPressed: (() => supprimer(ville)),
                  ),
                  onTap: () {
                    setState(() {
                      villeChoisie = ville;
                      coordonnees();
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
        child: new Text(
            (villeChoisie == null) ? widget.villeDeLutilisateur : villeChoisie),
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
                  ajouter(str);
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

  void ajouter(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.add(str);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
  }

  void supprimer(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    villes.remove(str);
    await sharedPreferences.setStringList(key, villes);
    obtenir();
  }

  void coordonnees() async {
    String str;
    if (villeChoisie == null) {
      str = widget.villeDeLutilisateur;
    } else {
      str = villeChoisie;
    }
    List<Placemark> coord = await Geolocator().placemarkFromAddress(str);
    if (coord != null) {
      coord.forEach((Placemark) => print(Placemark.position));
    }
  }
}

// List<Placemark> placemark = await Geolocator().placemarkFromAddress("Gronausestraat 710, Enschede");

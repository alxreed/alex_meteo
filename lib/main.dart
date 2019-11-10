import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import './api.dart';
import 'package:http/http.dart' as http;
import 'temps.dart';
import 'dart:convert';
import 'my_flutter_app_icons.dart';

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
  Temps tempsActuel;

  @override
  void initState() {
    super.initState();
    obtenir();
    appelApi();
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
                      appelApi();
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
                      appelApi();
                      Navigator.pop(context);
                    });
                  },
                );
              }
            },
          ),
        ),
      ),
      body: (tempsActuel == null)
          ? Center(
              child: new Text((villeChoisie == null)
                  ? widget.villeDeLutilisateur
                  : villeChoisie),
            )
          : new Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage(assetName()), fit: BoxFit.cover)),
              padding: EdgeInsets.all(20),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  textAvecStyle(tempsActuel.name, fontSize: 30.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      textAvecStyle("${tempsActuel.temp.toInt()}°C",
                          fontSize: 60.0),
                      new Image.asset(tempsActuel.icon)
                    ],
                  ),
                  textAvecStyle(tempsActuel.main, fontSize: 30.0),
                  textAvecStyle(tempsActuel.description, fontSize: 25.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Column(
                        children: <Widget>[
                          textAvecStyle("Pressure", fontSize: 15.0),
                          textAvecStyle("${tempsActuel.pression}",
                              fontSize: 20.0)
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          textAvecStyle("Humidity", fontSize: 15.0),
                          textAvecStyle("${tempsActuel.humidity}",
                              fontSize: 20.0)
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          textAvecStyle("Max", fontSize: 15.0),
                          textAvecStyle("${tempsActuel.temp_max}",
                              fontSize: 20.0)
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          textAvecStyle("Min", fontSize: 15.0),
                          textAvecStyle("${tempsActuel.temp_min}",
                              fontSize: 20.0)
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  String assetName() {
    if (tempsActuel.icon.contains("n")) {
      return "assets/n.jpg";
    } else if (tempsActuel.icon.contains("01") ||
        tempsActuel.icon.contains("02") ||
        tempsActuel.icon.contains("03")) {
      return "assets/d1.jpg";
    } else {
      return "assets/d2.jpg";
    }
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

  void appelApi() async {
    String str;
    if (villeChoisie == null) {
      str = widget.villeDeLutilisateur;
    } else {
      str = villeChoisie;
    }
    List<Placemark> coord = await Geolocator().placemarkFromAddress(str);
    if (coord != null) {
      final lat = coord.first.position.latitude;
      final lon = coord.first.position.longitude;
      String langue = Localizations.localeOf(context).languageCode;
      final key = weather_api;

      String urlApi =
          "http://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&lang=$langue&APPID=$key";
      final reponse = await http.get(urlApi);
      if (reponse.statusCode == 200) {
        Temps temps = new Temps();
        Map map = json.decode(reponse.body);
        temps.fromJSON(map);
        setState(() {
          tempsActuel = temps;
        });
      }
    }
  }
}

// List<Placemark> placemark = await Geolocator().placemarkFromAddress("Gronausestraat 710, Enschede");

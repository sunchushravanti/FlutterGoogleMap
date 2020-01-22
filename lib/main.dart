import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_map/MapLocation.dart';
import 'package:geolocator/geolocator.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map Sample App',
      theme: ThemeData(
        primaryColor: Colors.green[300],
      ),
      home:Container(
      decoration: BoxDecoration(
      image: DecorationImage(
      image: AssetImage("assets/google_map.jpeg"), fit: BoxFit.cover)),
    child:MyHomePage(),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<MyHomePage>  with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    _checkGpsandInternet();
  }

  //Checking Internet and GPS connection
  Future _checkGpsandInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi)){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get gurrent location"),
                content:
                const Text('Please make sure you enable GPS and Internet Connection.\n Please try again'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      final AndroidIntent intent = AndroidIntent(
                          action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                      intent.launch();
                      exit(0);
                    },
                  ),
                ],
              );
            },
          );
    } else {
      if (!(await Geolocator().isLocationServiceEnabled())) {
        if (Theme.of(context).platform == TargetPlatform.android) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get gurrent location"),
                content:
                const Text('Please make sure you enable GPS.\n Please try again'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      final AndroidIntent intent = AndroidIntent(
                          action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                      intent.launch();
                      exit(0);
                    },
                  ),
                ],
              );
            },
          );
        }
      }
      if ((await Geolocator().isLocationServiceEnabled())) {
        new Future.delayed(
            const Duration(seconds: 3),
                () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => MapLocation()),
            ));
      }
    }

    }


  //Splash SCreen
  @override
  Widget build(BuildContext context) {
    //User ID
    return new Scaffold(
      backgroundColor: Colors.transparent,
        body: new Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        new Container(
        //child: new Image.asset('assets/jaikisan_logo.png', height: 100.0, width: 100.0,),
          child:new Text('Map Integration ', textAlign: TextAlign.center,style:TextStyle (color: Colors.black,fontSize: 35,fontWeight:FontWeight.bold )),

        ),
        SizedBox(height: 20,),
          new Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text('Area Calculation ', textAlign: TextAlign.center,style:TextStyle (color: Colors.black,fontSize: 25,fontWeight:FontWeight.bold )),
          ]
          )),

        ])
    )
    );
  }
}

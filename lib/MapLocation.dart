import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' ;
import 'package:google_maps_flutter/google_maps_flutter.dart'as LatLng ;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as MapLL;

//Stateful Widget
class MapLocation extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MapLocation> {
  
  //Fields
  LatLng.BitmapDescriptor bitmapDescriptor;
  GoogleMapController mapController;
  Marker m;
  int marker_length=0;
  List<LatLng.LatLng> latlngList= new List();
  List<MapLL.LatLng> mapLL= new List();
  Map<MarkerId, Marker> new_markers = <MarkerId, Marker>{};
  final Set<Polygon>_polyline={};
  List<Placemark > placemark;
  String _address;

  
  //Map Controller
  void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
  }


//custom Marker Icon
  createCustomMarker(context){
    if(bitmapDescriptor==null){
      ImageConfiguration configuration = createLocalImageConfiguration(context);
      LatLng.BitmapDescriptor.fromAssetImage(configuration, "assets/mapmarker.png").then((icon) {
        setState(() {
          bitmapDescriptor=icon;
        });
      });
    }
   }


  //getting the marker address
  void getAddress(double latitude,double longitude) async{
    placemark =await Geolocator().placemarkFromCoordinates(latitude, longitude);
    _address= placemark[0].name.toString() + ", " +placemark[0].subLocality.toString() + ", "+placemark[0].locality.toString()+", Postal Code: " + placemark[0].postalCode.toString();
  }

  //Application Exit Code
  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Are you sure to exit ?",style:TextStyle(fontSize: 22,fontWeight: FontWeight.bold, color: Colors.white),),
            backgroundColor: Colors.green[300],
            content:Text("Your Data will be erased!!",style:TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.white),),
            actions: <Widget>[
              FlatButton(
                child: Text("NO",style:TextStyle(fontSize: 15, color: Colors.white),),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text("YES",style:TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.white),),
                onPressed: ()=> exit(0),
              ),
            ],
          );
        }
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   }

  @override
  Widget build(BuildContext context) {
    createCustomMarker(context);
    return WillPopScope(
        onWillPop: _onBackPressed,
        child:  Scaffold(
          appBar: AppBar(
              title: Text('Map Sample App',style:TextStyle(color: Colors.white)),
              backgroundColor: Colors.green[300],
              leading: Icon(Icons.map,color: Colors.white,),
              actions: <Widget>[
                //Reset Icon
                IconButton(color: Colors.white, icon: Icon(Icons.refresh,),onPressed: clearAll,),
              ]
          ),


          body:Column(
            children:<Widget>[
              Container(
                height: MediaQuery.of(context).size.width * 1.55,
                child:GoogleMap(
                  polygons:_polyline,
                  markers: Set<Marker>.of(new_markers.values),
                  onTap: (pos) {
                    setState(() {
                      //Adding marker on the map
                      applyingData(pos);
                    });
                    print("Caluclated Area: ${SphericalUtil.computeArea(mapLL)}");
               
                  },

                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: new LatLng.LatLng(19.076090, 72.877426),
                    zoom: 11.0,
                  ),
                ),
              ),

              SizedBox(height: 10,),
              Container(
                child:Column(
                  children: <Widget>[
                    Text('Area of Selected Portion: ${SphericalUtil.computeArea(mapLL) * 10.764 } in SQR FEET',textAlign: TextAlign.left,style:TextStyle(fontSize: 14,fontWeight: FontWeight.bold,),),
                    SizedBox(height: 10,),
                    Text('Area of Selected Portion: ${SphericalUtil.computeArea(mapLL) / 4047 } in ACRES',textAlign: TextAlign.left,style:TextStyle(fontSize: 14,fontWeight: FontWeight.bold,),)
                  ],
                )
              )
            ],
            )
          )
        );
  }

applyingData(LatLng.LatLng pos){
  final MarkerId markerId = MarkerId((marker_length++).toString());
  getAddress(pos.latitude, pos.longitude);
  m=  Marker(markerId: markerId,icon:bitmapDescriptor,position: pos,infoWindow: LatLng.InfoWindow(title: _address),);
  new_markers[markerId]=m;
  latlngList.add(new LatLng.LatLng(pos.latitude,pos.longitude));
  mapLL.add(new MapLL.LatLng(pos.latitude,pos.longitude));

  //Creating Area for selected markers
  _polyline.add(Polygon(
    polygonId: PolygonId((marker_length++).toString()),
    visible: true,
    points: latlngList,
    fillColor: Colors.lightGreen[300],
    strokeColor: Colors.lightGreen[300],
    strokeWidth: 10,
  ));
}

//Reseting all the markers, polygons and area
  void clearAll() {
    setState(() {
      latlngList.clear();
      mapLL.clear();
      new_markers.clear();
      _polyline.clear();
      _polyline.remove(latlngList);

    });

  }
}
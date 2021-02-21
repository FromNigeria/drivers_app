import 'dart:async';

import 'package:drivers_app/brand_colors.dart';
import 'package:drivers_app/datamodels/driver.dart';
import 'package:drivers_app/globalvariables.dart';
import 'package:drivers_app/helpers/pushnotificationservice.dart';
import 'package:drivers_app/widget/AvailabilityButton.dart';
import 'package:drivers_app/widget/ConfirmSheet.dart';
import 'package:drivers_app/widget/TaxiButton.dart';
import 'package:drivers_app/widget/notificationdialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';


import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();


  DatabaseReference tripRequestRef;

  var geoLocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String availabilityTitle = 'Go Online';
  Color availabilityColor = BrandColors.colorGreen;

  bool isAvailable = false;


  void getCurrentPosition() async {

    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    //CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));

  }

  void getCurrentDriverInfo () async {
    currentFirebaseUser = await FirebaseAuth.instance.currentUser();
    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}');
    driverRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){
        currentDriverInfo = Driver.fromSnapshot(snapshot);
       // print(currentDriverInfo.fullName);
      }

    });

    PushNotificationService pushNotificationService = PushNotificationService(); //initializing the clsss PushNoti

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }

  //then we can initialize using initState
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),

        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              AvailabilityButton(
              title: availabilityTitle,
                color: availabilityColor,
                onPressed: (){

                  showModalBottomSheet(
                    isDismissible: false,
                      context: context,
                      builder: (BuildContext context) => ConfirmSheet(
                        title: (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                        subtitle: (!isAvailable) ? 'You are about to be available to receive RIDE REQUEST' : 'You will stop receiving Now',

                        onPressed: (){
                          if(!isAvailable){
                               GoOnline();
                               getLocationUpdates();
                               Navigator.pop(context);

                               setState(() {
                                 availabilityColor = BrandColors.colorGreen;
                                 availabilityTitle = 'GO OFFLINE';
                                 isAvailable = true;

                               });
                          }
                          else {

                            goOffline();
                            Navigator.pop(context);
                            setState(() {
                              availabilityColor = BrandColors.colorAccentPurple;
                              availabilityTitle = 'GO ONLINE';
                              isAvailable = false;

                            });

                          }
                        },

                      ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void GoOnline(){
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    tripRequestRef.set('waiting....');

    tripRequestRef.onValue.listen((event) {

    });
  }

  void goOffline(){
    Geofire.removeLocation(currentFirebaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();

    tripRequestRef = null;
  }

  void getLocationUpdates(){

    homeTabPositionStream = geoLocator.getPositionStream(locationOptions).listen((Position position) {

      currentPosition = position;

      Geofire.setLocation(currentFirebaseUser.uid, position.latitude, position.longitude);
      LatLng pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }
}

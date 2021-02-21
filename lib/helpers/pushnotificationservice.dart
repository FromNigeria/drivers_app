
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/datamodels/tripdetails.dart';
import 'package:drivers_app/globalvariables.dart';
import 'package:drivers_app/widget/ProgressDialog.dart';
import 'package:drivers_app/widget/notificationdialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService {

  final FirebaseMessaging fcm = FirebaseMessaging();

  Future initialize(context) async {

    if(Platform.isIOS){
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message),context);

      },
      onLaunch: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message),context);
      },
      onResume: (Map<String, dynamic> message) async {

        fetchRideInfo(getRideID(message),context);

      },
    );

  }

  Future<String> getToken() async {

    String token = await fcm.getToken();
    print('token: $token');

    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

    //in case i want to send notification messages all all drivers that i have subscribe to
    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');

  }

  String getRideID(Map<String, dynamic> message){

    String rideID = '';

    if(Platform.isAndroid){
       rideID = message['data']['ride_id'];
    }
    else{
      rideID = message['ride_id'];
      print('ride_id: $rideID');
    }
    return rideID;
  }

  void fetchRideInfo(String rideID,context ){

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'fetching Details....',),

    );

    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('rideRequest/$rideID');
    //retrieve the values from data snapshot
    rideRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){


        assetsAudioPlayer.open(
          Audio('sounds/alert.mp3'),
        );
        assetsAudioPlayer.play();

      double pickupLat = double.parse(snapshot.value['location']['latitude'].toString());
      double pickupLng = double.parse(snapshot.value['location']['longitude'].toString());
      String pickupAddress = snapshot.value['pickup_address'].toString();

      //destination
      double destinationLat = double.parse(snapshot.value['destination']['latitude'].toString());
      double destinationLng = double.parse(snapshot.value['destination']['longitude'].toString());
      String destinationAddress = snapshot.value['destination_address'];
      String paymentMethod = snapshot.value['payment_method'];
      String riderName = snapshot.value['rider_name'];
      String riderPhone = snapshot.value['rider_phone'];

      //lets create a new instance of that TripDetails class
        TripDetails tripDetails = TripDetails();//this ishow you create instance of a class
        tripDetails.rideID = rideID;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderPhone = riderPhone;


        showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NotificationDialog(tripDetails: tripDetails,),
      );

      }
    });
  }
}
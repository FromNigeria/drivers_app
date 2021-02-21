
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:drivers_app/datamodels/directiondetails.dart';
import 'package:drivers_app/globalvariables.dart';
import 'package:drivers_app/helpers/requesthelper.dart';
import 'package:drivers_app/widget/ProgressDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HelperMethods{


  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {

    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapkey';

    var response = await RequestHelpers.getRequest(url);

    if(response == 'failed'){
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }
      ///Customers Trip calculations
  static int estimateFares (DirectionDetails details, int durationValue){
    ///per km  = N250
    /// per minute = N10
    /// per fare = N75
    double baseFare = 50;
    double distanceFare = (details.distanceValue/1000) * 60;
    double timeFare = (durationValue / 60) * 10;

    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

   static double generateRandomNumber(int max){
    var randomGenerator = Random();
     int randInt  = randomGenerator.nextInt(max);
      return randInt.toDouble();
   }

  static void disableHomTabLocationUpdates(){
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static void enableHomTabLocationUpdates(){
    homeTabPositionStream.resume();
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
  }

  static void showProgressDialog(context){

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Please wait',),
    );
  }
}
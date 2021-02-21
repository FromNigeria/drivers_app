import 'package:drivers_app/brand_colors.dart';
import 'package:drivers_app/datamodels/tripdetails.dart';
import 'package:drivers_app/globalvariables.dart';
import 'package:drivers_app/helpers/helpermethods.dart';
import 'package:drivers_app/screen/newtripspage.dart';
import 'package:drivers_app/widget/BrandDivider.dart';
import 'package:drivers_app/widget/ProgressDialog.dart';
import 'package:drivers_app/widget/TaxiButton.dart';
import 'package:drivers_app/widget/TaxiOutlineButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class NotificationDialog extends StatelessWidget {

  final TripDetails tripDetails;
  NotificationDialog({this.tripDetails});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60.0),
      ),
      elevation: 0.0,
        backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            SizedBox(height: 30.0,),

            Image.asset('images/taxi.png', width: 100,),

            SizedBox(height: 16.0,),

            Text('New Ride Request', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 16) ,),

            SizedBox(height: 30.0,),

            Padding(
               padding: EdgeInsets.all(16.0),
              child: Column(

                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Image.asset('images/pickicon.png', height: 16, width: 16,),
                      SizedBox(width: 16.0,),

                      Expanded(child: Container(child: Text(tripDetails.pickupAddress, overflow: TextOverflow.visible, style: TextStyle( fontSize: 13.5),))),
                    ],
                  ),

                  SizedBox(height: 15,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      Image.asset('images/desticon.png', height: 16, width: 16,),
                      SizedBox(width: 18.0,),

                      Expanded(child: Container(child: Text(tripDetails.destinationAddress, style: TextStyle( fontSize: 15),))),
                    ],
                  ),

                ],
              ),
            ),

            SizedBox(height: 20.0,),

            BrandDivider(),

            SizedBox(height: 8,),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [

                  Expanded(
                    child: Container(
                      child: TaxiOutlineButton(
                        title: 'DECLINE',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                        assetsAudioPlayer.stop();
                        Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 10,),

                  Expanded(
                    child: Container(
                      child: TaxiButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailability(context);
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),

            SizedBox(height: 10.0,),

          ],
        ),
      ),
    );
  }

  void checkAvailability(context){

    //show please wait dialog
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Accepting Ride Request',),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance.reference().child('drivers/${currentFirebaseUser.uid}/newtrip');
    newRideRef.once().then((DataSnapshot snapshot){

      Navigator.pop(context);
      Navigator.pop(context);

      String thisRideID = "";
      if(snapshot.value != null){
      thisRideID = snapshot.value.toString();
      }
      else{
        print('no ride request found');
      }

      if(thisRideID == tripDetails.rideID){
      newRideRef.set('accepted');
      HelperMethods.disableHomTabLocationUpdates();
      Navigator.push(
          context,
        MaterialPageRoute(builder: (context) => NewTripPage(tripDetails: tripDetails,),
        ));
      }
      else if (thisRideID == 'cancelled'){
        Toast.show("Ride has been cancelled", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
      else if (thisRideID == 'timeout'){
        Toast.show("ride has timed out", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
      else{
        Toast.show("No Ride Request Found", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }

    });
  }
}

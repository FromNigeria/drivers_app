import 'package:drivers_app/brand_colors.dart';
import 'package:drivers_app/globalvariables.dart';
import 'package:drivers_app/screen/mainpage.dart';
import 'package:drivers_app/widget/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VehicleInfoPage extends StatelessWidget {



  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldkey.currentState.showSnackBar(snackbar);
  }

  static const String id = 'vehicleinfo';

  var carModelController = TextEditingController();
  var carColorController = TextEditingController();
  var vehicleNumberController = TextEditingController();

  void updateProfile(context){

    String id = currentFirebaseUser.uid;
    DatabaseReference driverRef =
    FirebaseDatabase.instance.reference().child('drivers/$id/vehicle_details');

    Map map = {
      'car_color': carColorController.text,
      'car_model': carModelController.text,
      'vehicle_number': vehicleNumberController.text,
    };

    driverRef.set(map);

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(

            children: <Widget> [

              SizedBox(height: 20,),

              Image.asset('images/logo.png', height: 110, width: 110, ),

              Padding(
                padding:  EdgeInsets.fromLTRB(30,20, 30,30),
                child: Column(
                  children: <Widget> [

                    SizedBox(height: 10,),

                    Text('Enter Car details', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 22),),

                    SizedBox(height: 25,),

                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car Model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,

                        )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 10,),

                    TextField(
                      controller: carColorController,
                      decoration: InputDecoration(
                          labelText: 'Car Color',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 10,),

                    TextField(
                      controller: vehicleNumberController,
                      maxLength: 11,
                      decoration: InputDecoration(
                        counterText: '',
                          labelText: 'Vehicle Number',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),

                    SizedBox(height: 40,),

                    TaxiButton(
                      color: BrandColors.colorGreen,
                      title: 'PROCEED',
                      onPressed: (){

                        if(carModelController.text.length < 3 ){
                          showSnackBar('Please enter your correct car model');
                          return;
                        }

                        if(carColorController.text.length < 3 ){
                          showSnackBar('Please use your correct car color');
                          return;
                        }

                        if(vehicleNumberController.text.length < 3 ){
                          showSnackBar('Please enter your correct vehicle number');
                          return;
                        }

                        updateProfile(context);

                      },
                    )


                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

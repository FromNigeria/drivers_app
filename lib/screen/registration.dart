import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:drivers_app/brand_colors.dart';
import 'package:drivers_app/constants.dart';
import 'package:drivers_app/globalvariables.dart';
import 'package:drivers_app/screen/login.dart';
import 'package:drivers_app/screen/mainpage.dart';
import 'package:drivers_app/screen/vehicleinfo.dart';
import 'package:drivers_app/widget/ProgressDialog.dart';
import 'package:drivers_app/widget/TaxiButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Registration extends StatefulWidget {

  static const String id = 'register';

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {

  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldkey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var fullNameController = TextEditingController();

  var phoneNumberController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser() async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Creating Account....',),

    );

    final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){

      //checking error and display message
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);

    })).user;

    Navigator.pop(context);
    //checking if user registration is successful
    if(user != null){
      DatabaseReference newUserRef  = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');

      //prepare data to be save on users table
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneNumberController.text,
      };

      newUserRef.set(userMap);

      currentFirebaseUser = user;

      //Take user to main page
      Navigator.pushNamed(context, VehicleInfoPage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(

              children: <Widget>[
                Padding(
                  padding:  EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: Container(

                    child: Text(' Alpha Logistics ',
                      style: Constants.boldHeading,

                    ),

                  ),
                ),
                // Padding(
                //   padding:  EdgeInsets.only(
                //     top:17.0,
                //   ),
                //   child: Container(
                //
                //     child: Text('- For Ibadan Residents & Public and Private Workers Only -',
                //       textAlign: TextAlign.center,
                //       style: Constants.regularHeading,
                //
                //     ),
                //
                //   ),
                // ),
                SizedBox(height: 40,),
                Image(
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                  image: AssetImage('images/taxi.png'),
                ),

                SizedBox(height: 40,),
                Text("Register as DRIVER",
                  style: Constants.boldHeading,
                  textAlign: TextAlign.center,
                  // style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),

                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[

                      //Full Name
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10,),

                      //Email Address
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10,),

                      //Phone Number
                      TextField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 14,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10,),

                      //Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 40,),

                      //Raised Button
                      TaxiButton(
                        title: 'REGISTER',
                        color: BrandColors.colorGreen,
                        onPressed: () async {

                          //network availability
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No Internet Connection now');
                            return;
                          }

                          if(fullNameController.text.length < 3){
                            showSnackBar('please enter valid fullname');
                            return;
                          }
                          if(phoneNumberController.text.length < 10){
                            showSnackBar('please enter valid phone number');
                            return;
                          }

                          if(!emailController.text.contains('@')){
                            showSnackBar('please provide a valid email address');
                            return;
                          }

                          if(passwordController.text.length < 8){
                            showSnackBar('password must be at least 8 characters');
                            return;
                          }

                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),


                FlatButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                  },
                  child: Text('Already have a DRIVER Account? Login'),
                ),



              ],
            ),
          ),
        ),
      ),

    );
  }
}

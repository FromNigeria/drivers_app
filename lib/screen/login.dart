import 'package:connectivity/connectivity.dart';
import 'package:drivers_app/brand_colors.dart';
import 'package:drivers_app/constants.dart';
import 'package:drivers_app/screen/mainpage.dart';
import 'package:drivers_app/screen/registration.dart';
import 'package:drivers_app/widget/ProgressDialog.dart';
import 'package:drivers_app/widget/TaxiButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {

  static const String id = 'login ';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
    );
    scaffoldkey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'logging in....',),

    );
    
    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){

      //checking error and display message
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);

    })).user;

    if(user != null) {
    //verify login
      DatabaseReference userRef  = FirebaseDatabase.instance.reference().child('drivers/${user.uid}');
      userRef.once().then((DataSnapshot snapshot) => {

        if(snapshot.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false)
        }
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    key: scaffoldkey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(

              children: <Widget>[
                Padding(
                  padding:  EdgeInsets.only(
                    top: 24.0,
                  ),
                  child: Container(

                    child: Text(' Alpha Logistics ',
                      style: Constants.boldHeading,

                    ),

                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(
                    top: 24.0,
                  ),
                  child: Container(

                    child: Text('- For Ibadan Residents & Public and Private Workers Only -',
                      textAlign: TextAlign.center,
                      style: Constants.regularHeading,

                    ),

                  ),
                ),
                SizedBox(height: 70,),
                Image(
                  alignment: Alignment.center,
                  height: 100,
                  width: 100,
                  image: AssetImage('images/taxi.png'),
                ),

                SizedBox(height: 40,),
                Text("Login as Driver",
                  textAlign: TextAlign.center,
                  style: Constants.boldHeading,
                  // style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),

                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email Address',
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

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
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

                      SizedBox(height: 40,),

                      //Raised Button
                      TaxiButton(
                        title: 'LOGIN',
                        color: BrandColors.colorBlue,
                        onPressed: () async {

                          //network availability
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No Internet Connection now');
                            return;
                          }

                          if(!emailController.text.contains('@')){
                          showSnackBar('Abeg enter your correct email');
                          return;
                          }

                          if(passwordController.text.length <8){
                            showSnackBar('This Password is too short abeg');
                            return;
                          }

                          login();
                        },
                      ),
                  ],
                  ),
                ),


                FlatButton(
                  onPressed: (){
                  Navigator.pushNamedAndRemoveUntil(context, Registration.id, (route) => false);
                  },
                  child: Text('iDon\'t have an Account yet, Okay Sign Up Here'),
                ),



              ],
            ),
          ),
        ),
      ),

    );
  }
}



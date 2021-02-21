import 'dart:io';

import 'package:drivers_app/constants.dart';
import 'package:drivers_app/globalvariables.dart';
import 'package:drivers_app/screen/login.dart';
import 'package:drivers_app/screen/mainpage.dart';
import 'package:drivers_app/screen/registration.dart';
import 'package:drivers_app/screen/vehicleinfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions (
      googleAppID: '1:308125060889:ios:72588b5b54d30e1935ff88',
      gcmSenderID: '308125060889',//308125060889
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:308125060889:android:9d820a9b03863dc435ff88',
      apiKey: 'AIzaSyBbBYQ3WtYGAx1gTwuAK37gsS_GToJwZr8',
      databaseURL: 'https://alpha-logistics-ride-default-rtdb.firebaseio.com',
    ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();
  //lets confirm if the currentuser instance is null or not

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        fontFamily: 'Brand-Regular',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
          initialRoute:(currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
          routes: {
            MainPage.id: (context) => MainPage(), //MainPage.id: (context) => MainPage()
            Registration.id: (context) => Registration(),
            VehicleInfoPage.id: (context) => VehicleInfoPage(),
            LoginPage.id: (context) => LoginPage(),
          },
    );
  }
}


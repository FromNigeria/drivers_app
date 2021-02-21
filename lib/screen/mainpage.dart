import 'package:drivers_app/brand_colors.dart';
import 'package:drivers_app/tabs/earningstab.dart';
import 'package:drivers_app/tabs/hometab.dart';
import 'package:drivers_app/tabs/profiletab.dart';
import 'package:drivers_app/tabs/ratingstab.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  //tap controller
  TabController tabController;
  int selectedIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length:  4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: <Widget> [
          HomeTab(),
          EarningsTab(),
          RatingsTab(),
          ProfileTab(),
        ],
      ),

      //Bottom Navigation Bars
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
         BottomNavigationBarItem(
             icon: Icon(Icons.home),
              //label: 'Home',
           title: Text('Home'),
         ),

          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_rounded),
            //label: 'Home',
            title: Text('Driver Earnings'),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            //label: 'Home',
            title: Text('Ratings'),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            //label: 'Home',
            title: Text('Account'),
          ),

        ],
        currentIndex: selectedIndex,
        unselectedItemColor: BrandColors.colorIcon,
        selectedItemColor: BrandColors.colorAccentPurple,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
      ),
    );
  }
}

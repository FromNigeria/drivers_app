import 'package:drivers_app/brand_colors.dart';
import 'package:drivers_app/helpers/helpermethods.dart';
import 'package:drivers_app/widget/BrandDivider.dart';
import 'package:drivers_app/widget/TaxiButton.dart';
import 'package:flutter/material.dart';


class CollectPayment extends StatelessWidget {

  final String paymentMethod;
  final int fares;

  CollectPayment({this.paymentMethod, this.fares});


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            SizedBox(height: 20,),

            Text('${paymentMethod.toUpperCase()} PAYMENT'),

            SizedBox(height: 20,),

            BrandDivider(),

            SizedBox(height: 16.0,),

            Text('\N$fares', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 50),),

            SizedBox(height: 16,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Amount above is the total fares to be charged to the rider', textAlign: TextAlign.center,),
            ),

            SizedBox(height: 30,),

            Container(
              width: 230,
              child: TaxiButton(
                title: (paymentMethod == 'cash') ? 'COLLECT CASH' : 'CONFIRM',
                color: BrandColors.colorGreen,
                onPressed: (){

                  Navigator.pop(context);
                  Navigator.pop(context);

                  HelperMethods.enableHomTabLocationUpdates();

                },
              ),
            ),

            SizedBox(height: 40,)
          ],
        ),
      ),
    );
  }
}


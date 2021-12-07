import 'package:flutter/material.dart';
import 'package:uber_clone_flutter_udemy/src/utils/colors.dart' as utils;
class ButtonApp extends StatelessWidget {

   Color color;
   Color textColor;
   String text;
   IconData icon;
   Function onPressed;


  ButtonApp({
    this.color = utils.Colors.uberCloneColor,
    this.textColor = Colors.white,
     this.text,
    this.onPressed,
    this.icon = Icons.arrow_forward_ios,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: (){
        onPressed();

      },
      color: color,
      textColor: textColor,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                    text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold

                  ),

                )

            ),

          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 50,
              child: CircleAvatar(
                radius: 15,
                child: Icon(
                    icon,
                  color: utils.Colors.uberCloneColor,
                ),
                backgroundColor: Colors.white,
              ),
            ),
          )

        ],

      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)

      ),


    );
  }
}

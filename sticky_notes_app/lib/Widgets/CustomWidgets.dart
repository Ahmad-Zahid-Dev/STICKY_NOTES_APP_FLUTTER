import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomWidgets {

  Widget CustomTextField(controller, int lines ){
    return TextField(
      maxLines: lines,
      maxLength: null,
      controller: controller,
      decoration: InputDecoration(
        border:OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius:BorderRadius.circular(15.r)
        ),
      ),
    );
  }

  Widget Customdrawer(){
     return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: (){
            // Signout fnc
           
            }, 
            
            icon: Icon(Icons.logout_outlined,size: 60,)),
            Text('Sign out',style: TextStyle(fontSize: 30.sp),),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTab;
  final String text;
  const MyButton({super.key, required this.onTab, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTab,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: 
          ShapeDecoration(
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
              ),
            ),
          
          child: Text(
            text,
            style:const TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 15,
              color: Colors.white,
            ),),
        ),
      ),
    );
  }
}

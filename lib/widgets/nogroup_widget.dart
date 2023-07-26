import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NoGroupWidget extends StatelessWidget {
  const NoGroupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column( 
      children: const [ 
        Icon(Icons.add, color: Colors.grey, size: 30,),
        Text("You Do Not Have Any Groups Now", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),)
      ],
    );
  }
}
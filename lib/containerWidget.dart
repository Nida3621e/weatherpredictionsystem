import 'package:flutter/material.dart';

class Containerwidget extends StatefulWidget {
  final String image;
  final String name;
  final Widget materialApp;
  const Containerwidget({super.key, required this.image, required this.name, required this.materialApp});

  @override
  State<Containerwidget> createState() => _ContainerwidgetState();
}

class _ContainerwidgetState extends State<Containerwidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget.materialApp,));
      },
        child: Container(
          padding: EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width*0.4,
          height: MediaQuery.of(context).size.height*0.23,
          decoration: BoxDecoration(
              color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: Colors.grey,
              offset: Offset(3,5)
            )]
          ),
          child: Column(
            children: [
              Image.asset("${widget.image}",height: MediaQuery.of(context).size.height*0.15 ,),
              Text("${widget.name}")
            ],
          ),
        ),
    );
  }
}

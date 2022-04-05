import 'package:flutter/material.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions;
  final IconData icon;
  const CustomDialogBox({this.title, this.descriptions, this.icon});

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0, bottom: 0),
          margin: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Text(
                widget.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.descriptions,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: MaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    child: Text("J'ai Compris"),
                    color: Colors.blue,
                    textColor: Colors.white,
                    // height: 40,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
        Positioned(
          bottom: 110,
          left: 0.0,
          right: 0.0,
          child: Container(
            width: 150,
            height: 150,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 50,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(140 / 2),
                  child: Icon(
                    widget.icon,
                    size: 80,
                    color: Colors.red,
                  )),
            ),
          ),
        )
      ],
    );
  }
}

customPopup(context, title, body, icon) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogBox(
          title: title,
          descriptions: body,
          icon: icon,
        );
      });
}

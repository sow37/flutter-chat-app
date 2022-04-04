import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewGroupePage extends StatefulWidget {
  final SharedPreferences prefs;

  NewGroupePage({this.prefs});

  @override
  State<StatefulWidget> createState() {
    return new NewGroupePageState();
  }
}

class NewGroupePageState extends State<NewGroupePage> {
  final db = FirebaseFirestore.instance;
  CollectionReference groupReference;
  DocumentSnapshot groupsnapshot;
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();
  String fileUrl = "";

  bool editName = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    groupReference = db.collection("groups");
    print("########### profileReference ${groupReference.path}");

    // groupReference.snapshots().listen((querySnapshot) {
    //   groupsnapshot = querySnapshot;
    //   widget.prefs.setString('name', groupsnapshot.get("name"));
    //   print("########### username ${groupsnapshot.get("name")}");
    //   widget.prefs
    //       .setString('profile_photo', groupsnapshot.get("profile_photo"));

    //   // setState(() {
    //   //   _yourNameController.text = profileSnapshot.get("name");
    //   // });
    // });
  }

  Future<void> getGroupPicture() async {
    var imageUrl;
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    Reference storageReference =
        FirebaseStorage.instance.ref().child('group/picture');
    await storageReference.putFile(image);
    print('File Uploaded');
    imageUrl = await storageReference.getDownloadURL();
    setState(() {
      fileUrl = imageUrl;
    });

    // groupReference.update({'group_photo': fileUrl});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Text(
                    "Create a new group",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 50),
                Stack(
                  children: [
                    Container(
                      width: 190.0,
                      height: 190.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage('${fileUrl}'),
                        ),
                      ),
                      child: fileUrl != ""
                          ? null
                          : Icon(Icons.person, color: Colors.grey, size: 180),
                    ),
                    Positioned(
                        right: 10.0,
                        bottom: 10.0,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, size: 35),
                            onPressed: () {
                              getGroupPicture();
                            },
                          ),
                        ))
                  ],
                ),
                Form(
                  key: _formStateKey,

                  // autovalidate: true,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter Group\' Name';
                            }
                            if (value.trim() == "")
                              return "Only Space is Not Valid!!!";
                            return null;
                          },
                          controller: _yourNameController,
                          decoration: InputDecoration(
                            focusedBorder: new UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    width: 2, style: BorderStyle.solid)),
                            labelText: "Group's Name",
                            icon: Icon(Icons.group, size: 30),
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ),
    );
  }
}

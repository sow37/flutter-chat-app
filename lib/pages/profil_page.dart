import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  final SharedPreferences prefs;

  ProfilPage({this.prefs});

  @override
  State<StatefulWidget> createState() {
    return new ProfilPageState();
  }
}

class ProfilPageState extends State<ProfilPage> {
  final db = FirebaseFirestore.instance;
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();

  bool editName = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    profileReference =
        db.collection("users").doc(widget.prefs.getString('mobile'));
    print("########### profileReference ${profileReference.path}");

    profileReference.snapshots().listen((querySnapshot) {
      profileSnapshot = querySnapshot;
      widget.prefs.setString('name', profileSnapshot.get("name"));
      print("########### username ${profileSnapshot.get("name")}");
      widget.prefs
          .setString('profile_photo', profileSnapshot.get("profile_photo"));

      setState(() {
        _yourNameController.text = profileSnapshot.get("name");
      });
    });
  }

  Future<void> getProfilePicture() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profiles/${widget.prefs.getString('uid')}');
    await storageReference.putFile(image);
    print('File Uploaded');
    String fileUrl = await storageReference.getDownloadURL();
    profileReference.update({'profile_photo': fileUrl});
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
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (profileSnapshot != null
                    ? (profileSnapshot.get('profile_photo') != null
                        ? Stack(
                            children: [
                              Container(
                                width: 190.0,
                                height: 190.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        '${profileSnapshot.get('profile_photo')}'),
                                  ),
                                ),
                                child:
                                    profileSnapshot.get('profile_photo') != ""
                                        ? null
                                        : Icon(Icons.person,
                                            color: Colors.grey, size: 180),
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
                                      icon:
                                          Icon(Icons.upload_outlined, size: 35),
                                      onPressed: () {
                                        getProfilePicture();
                                      },
                                    ),
                                  ))
                            ],
                          )
                        : Container())
                    : Container()),
                SizedBox(
                  height: 20,
                ),
                (!editName && profileSnapshot != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            '${profileSnapshot.get("name" ?? "default data")}',
                            style: TextStyle(fontSize: 25),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                editName = true;
                              });
                            },
                          ),
                        ],
                      )
                    : Container()),
                (editName
                    ? Form(
                        key: _formStateKey,

                        // autovalidate: true,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Enter Name';
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
                                  labelText: "Your Name",
                                  icon: Icon(
                                    Icons.verified_user,
                                  ),
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container()),
                (editName
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton(
                            child: Text(
                              'UPDATE',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              if (_formStateKey.currentState.validate()) {
                                profileReference
                                    .update({'name': _yourNameController.text});
                                setState(() {
                                  editName = false;
                                });
                              }
                            },
                            color: Colors.lightBlue,
                          ),
                          MaterialButton(
                            elevation: 2.0,
                            child: Text('CANCEL'),
                            onPressed: () {
                              setState(() {
                                editName = false;
                              });
                            },
                          )
                        ],
                      )
                    : Container())
              ]),
        ),
      ),
    );
  }
}

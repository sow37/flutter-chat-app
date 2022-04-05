import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
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
  CollectionReference groupsReference;
  DocumentReference groupReference;
  DocumentSnapshot groupsnapshot;
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  String fileUrl = "";
  var image;
  bool isLoading = false;

  bool editName = false;
  bool isValide = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    groupsReference = db.collection("groups");
    print("########### profileReference ${groupsReference.path}");

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
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
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

  Future<void> _createGroupe() async {
    //create group's document
    groupReference = await groupsReference.doc();
    groupReference.set({
      'createdAt': FieldValue.serverTimestamp(),
      'name': _groupNameController.text,
      'admin': widget.prefs.getString('mobile'),
    });
    groupReference
        .collection('members')
        .doc(widget.prefs.getString('mobile'))
        .set({
      'memberId': widget.prefs.getString('mobile'),
    });
    // ((documentRef) {
    //   groupReference = documentRef;
    //   documentRef.get().then((docSnapshot) {
    //     if (docSnapshot.exists) {
    //       documentRef
    //           .collection("members")
    //           .doc(widget.prefs.getString('mobile'));
    //     }
    //   });
    // });

//
    // upload group's image
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('group/+${groupReference.id.toString()}');
    await storageReference.putFile(image);
    print('File Uploaded');
    fileUrl = await storageReference.getDownloadURL();

    //set group image
    await groupReference.update({'image': fileUrl});
    setState(() {
      isLoading = false;
    });
    print("Group created");
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomePage(
        prefs: widget.prefs,
        currentIndex: 1,
      ),
    ));
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
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                    Widget>[
              Center(
                child: Text(
                  "Create a new group",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 25),
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
              SizedBox(height: 30),
              Form(
                key: _formStateKey,

                // autovalidate: true,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter Group\' Name';
                          }
                          if (value.trim() == "")
                            return "Only Space is Not Valid!!!";

                          return null;
                        },
                        onChanged: (value) {
                          if (value != "") {
                            setState(() {
                              isValide = true;
                            });
                          } else {
                            setState(() {
                              isValide = false;
                            });
                          }
                        },
                        controller: _groupNameController,
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
              ),
              GestureDetector(
                onTap: () {
                  if (_groupNameController.text.trim() != "") {
                    setState(() {
                      isLoading = true;
                    });
                    _createGroupe();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isValide ? Colors.blue : Colors.blue.shade200,
                  ),
                  child: Center(
                    child: !isLoading
                        ? Text("Create",
                            style: TextStyle(color: Colors.white, fontSize: 16))
                        : CircularProgressIndicator(
                            color: Colors.white,
                          ),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}

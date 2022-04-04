import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/chat_page.dart';
import 'package:flutter_chat_app/pages/registration_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';

import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  final SharedPreferences prefs;
  HomePage({this.prefs});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _tabTitle = "Contacts";
  List<Widget> _children = [Container(), Container()];

  final db = FirebaseFirestore.instance;
  final ContactPicker _contactPicker = new ContactPicker();
  CollectionReference contactsReference;
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;

  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();
  bool editName = false;
  @override
  void initState() {
    super.initState();
    contactsReference = db
        .collection("users")
        .doc(widget.prefs.getString('mobile'))
        .collection('contacts');
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
    // profileReference
    //     .get()
    //     .then((value) => print("########### mobile ${value.get('mobile')}"));
  }

  generateContactTab() {
    return Column(
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
          stream: contactsReference.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Expanded(
                child: Center(
                    child: new Text(
                  "Loading...",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                )),
              );
            } else {
              if (snapshot.data.size == 0) {
                print("############ docs: ${snapshot.data.size}");
                return Expanded(
                  child: Center(
                      child: new Text(
                    "No Contacts",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                  )),
                );
              } else {
                print("############ has contacts docs: ${snapshot.data.size}");
                return Expanded(
                  child: new ListView(
                    children: generateContactList(snapshot),
                  ),
                );
              }
            }
          },
        )
      ],
    );
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

  generateProfileTab() {
    return Center(
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
                            child: profileSnapshot.get('profile_photo') != ""
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
                                  icon: Icon(Icons.upload_outlined, size: 35),
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
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
    );
  }

  generateContactList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map<Widget>(
          (doc) => InkWell(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
              child: ListTile(
                title: Text(doc["name"] ?? "no name"),
                subtitle: Text(doc["mobile"] ?? "no mobile phone"),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            onTap: () async {
              QuerySnapshot result = await db
                  .collection('chats')
                  .where('contact1',
                      isEqualTo: widget.prefs.getString('mobile'))
                  .where('contact2', isEqualTo: doc["mobile"])
                  .get();
              List<DocumentSnapshot> docs = result.docs;
              if (docs.length == 0) {
                result = await db
                    .collection('chats')
                    .where('contact2',
                        isEqualTo: widget.prefs.getString('mobile'))
                    .where('contact1', isEqualTo: doc["mobile"])
                    .get();
                docs = result.docs;
                if (docs.length == 0) {
                  await db.collection('chats').add({
                    'contact1': widget.prefs.getString('mobile'),
                    'contact2': doc["mobile"]
                  }).then((documentReference) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          prefs: widget.prefs,
                          chatId: documentReference.id,
                          title: doc["name"] ?? "no name",
                        ),
                      ),
                    );
                  }).catchError((e) {});
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        prefs: widget.prefs,
                        chatId: docs[0].id,
                        title: doc["name"] ?? "no name",
                      ),
                    ),
                  );
                }
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      prefs: widget.prefs,
                      chatId: docs[0].id,
                      title: doc["name"] ?? "no name",
                    ),
                  ),
                );
              }
            },
          ),
        )
        .toList();
  }

  openContacts() async {
    Contact contact = await _contactPicker.selectContact();
    if (contact != null) {
      String phoneNumber = contact.phoneNumber.number
          .toString()
          .replaceAll(new RegExp(r"\s\b|\b\s"), "")
          .replaceAll(new RegExp(r'[^\w\s]+'), '');
      if (phoneNumber.length == 9) {
        phoneNumber = '+221$phoneNumber';
      }
      if (phoneNumber.length == 12) {
        phoneNumber = '+$phoneNumber';
      }
      if (phoneNumber.length == 13) {
        DocumentReference userRef = db
            .collection("users")
            .doc(phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''));
        await userRef.get().then((documentReference) async {
          if (documentReference.exists) {
            contactsReference
                .doc(phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''))
                .set({
              'name': contact.fullName,
              'mobile': phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''),
            });

            // we also add current user to his contact's contact
            print("number:${widget.prefs.getString('mobile')}");
            CollectionReference contactsReference2 = db
                .collection("users")
                .doc(documentReference['mobile']
                    .toString()
                    .replaceAll(new RegExp(r'[^\w\s]+'), ''))
                .collection('contacts');
            contactsReference2.doc(widget.prefs.getString('mobile')).set({
              'name': widget.prefs.getString('name'),
              'mobile': widget.prefs
                  .getString('mobile')
                  .replaceAll(new RegExp(r'[^\w\s]+'), ''),
            });
          } else {
            print('################ User Not Registered');
          }
        }).catchError((e) {});
      } else {
        print('Wrong Mobile Number');
      }
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          _tabTitle = "Contacts";
          break;
        case 1:
          _tabTitle = "Profile";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      generateContactTab(),
      generateProfileTab(),
    ];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            openContacts();
          },
          child: Icon(Icons.add),
        ),
        drawer: Drawers(prefs: widget.prefs, profileSnapshot: profileSnapshot),
        appBar: AppBar(
          title: Text(_tabTitle),
        ),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: _currentIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: 'Contacts',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            )
          ],
        ),
      ),
    );
  }
}

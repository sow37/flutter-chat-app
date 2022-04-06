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
import '../widgets/popup.dart';

class HomePage extends StatefulWidget {
  final SharedPreferences prefs;
  int currentIndex;

  HomePage({this.prefs, this.currentIndex = 0});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _tabTitle = "Contacts";
  List<Widget> _children = [Container(), Container()];

  final db = FirebaseFirestore.instance;
  final ContactPicker _contactPicker = new ContactPicker();
  CollectionReference contactsReference;
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;
  CollectionReference groupsReference;
  DocumentReference groupReference;

  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();
  bool editName = false;
  @override
  void initState() {
    super.initState();

    print('############### widget.currentIndex ${widget.currentIndex}');
    onTabTapped(widget.currentIndex);

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

    // Groups
    groupsReference = db.collection("groups");
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
                    "No contacts",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                  )),
                );
              } else {
                print("############ has group docs: ${snapshot.data.size}");
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

  generateGroupTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: groupsReference.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Expanded(
                    child: Center(
                        child: new Text(
                      "Loading...",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    )),
                  );
                } else {
                  if (snapshot.data.size == 0) {
                    print("############ docs: ${snapshot.data.size}");
                    return Expanded(
                      child: Center(
                          child: new Text(
                        "No Groups",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w300),
                      )),
                    );
                  } else {
                    print(
                        "############ has contacts docs: ${snapshot.data.size}");
                    return Expanded(
                      child: new ListView(
                        children: generateGroupList(snapshot),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  generateGroupList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map<Widget>(
          (doc) => Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: new CircleAvatar(
                      child: null, backgroundImage: new NetworkImage(
                          // 'https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-afb7b.appspot.com/o/group%2F%2B55PfegubksFnvKwNBDqs?alt=media&token=0809e34c-7464-4e4f-a33f-3a18a7bb26bd'
                          doc['image'])),
                ),
                Expanded(child: Text(doc["name"] ?? "no name")),
                Icon(Icons.chevron_right)
              ],
            ),
          ),
        )
        .toList();
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
            customPopup(context, "User Not Registered",
                "User must signup to the app", Icons.error);
          }
        }).catchError((e) {});
      } else {
        print('Wrong Mobile Number');
        customPopup(
            context, "Wrong number", "Wrong mobile number", Icons.error);
      }
    }
  }

  void onTabTapped(int index) {
    setState(() {
      widget.currentIndex = index;
      switch (widget.currentIndex) {
        case 0:
          _tabTitle = "Contacts";
          break;
        case 1:
          _tabTitle = "Groups";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      generateContactTab(),
      generateGroupTab(),
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
        body: _children[widget.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: widget.currentIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: 'Contacts',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Groups',
            )
          ],
        ),
      ),
    );
  }
}

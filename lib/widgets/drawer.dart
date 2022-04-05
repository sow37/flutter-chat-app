import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/group/new_group_page.dart';
import 'package:flutter_chat_app/pages/profil_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/registration_page.dart';

class Drawers extends StatelessWidget {
  final SharedPreferences prefs;
  final DocumentSnapshot profileSnapshot;

  Drawers({
    Key key,
    ListView child,
    this.prefs,
    this.profileSnapshot,
  }) : super(key: key);

  // final db = FirebaseFirestore.instance;
  // DocumentReference profileReference;

  // profileReference =
  //       db.collection("users").doc(prefs.getString('mobile'));
  //   print("########### profileReference ${profileReference.path}");

  //   profileReference.snapshots().listen((querySnapshot) {
  //     profileSnapshot = querySnapshot;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(
              prefs.getString("mobile"),
              style: TextStyle(fontSize: 18),
            ),
            accountName: Text(
              profileSnapshot.get("name"),
              style: TextStyle(fontSize: 18),
            ),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilPage(prefs: prefs),
                  ),
                );
              },
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image:
                        NetworkImage('${profileSnapshot.get('profile_photo')}'),
                  ),
                ),
                child: profileSnapshot.get('profile_photo') != ""
                    ? null
                    : Icon(Icons.person, color: Colors.grey, size: 180),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          SizedBox(height: 30),
          ListTile(
              leading: Icon(Icons.group_add, color: Colors.blue),
              title: Text('New Group',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewGroupePage(prefs: prefs),
                  ),
                );
              }),
          ListTile(
              leading: Icon(Icons.info_sharp, color: Colors.blue),
              title: Text('About Us',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              onTap: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => ProfilPage(prefs: prefs),
                //   ),
                // );
              }),
          Divider(
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.blue),
              title: Text('Se Deconnecter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              onTap: () {
                // FirebaseAuth.instance.signOut().then((response) {
                prefs.remove('is_verified');
                prefs.remove('mobile');
                prefs.remove('mobile_number');
                prefs.remove('name');
                prefs.remove('profile_photo');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => RegistrationPage(prefs: prefs),
                  ),
                );
                // });
              },
            ),
          ),
        ],
      ),
    );
  }
}

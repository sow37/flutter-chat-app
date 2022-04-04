import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/pages/home_page.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  final SharedPreferences prefs;
  RegistrationPage({this.prefs});
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String smsOTP;
  String verificationId;
  String errorMessage = 'wrong number';
  FirebaseAuth _auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'SN';
  PhoneNumber phoneNo = PhoneNumber(isoCode: 'SN');
  bool inputError = false;
  int inputLength = 0;
  bool isLoading = false;

  @override
  initState() {
    super.initState();
  }

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {});
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo.phoneNumber, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
              smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (FirebaseAuthException e) {
            print('${e.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  // _auth.currentUser.then((user) async {
                  //   signIn();
                  // });

                  signIn();
                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      // final AuthCredential credential = PhoneAuthProvider.credential(
      //   verificationId: verificationId,
      //   smsCode: smsOTP,
      // );
      // final UserCredential user = await _auth.signInWithCredential(credential);
      // final User currentUser = await _auth.currentUser;
      // assert(user.user.uid == currentUser.uid);
      // Navigator.of(context).pop();
      DocumentReference userRef = db
          .collection("users")
          .doc(phoneNo.phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''));
      await userRef.get().then((documentRef) async {
        if (!documentRef.exists) {
          userRef.set({
            'name': "No Name",
            'mobile':
                phoneNo.phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''),
            'profile_photo': "",
          }).then((documentReference) {
            widget.prefs.setBool('is_verified', true);
            widget.prefs.setString(
              'mobile',
              phoneNo.phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''),
            );
            widget.prefs.setString('name', "No Name");
            widget.prefs.setString('profile_photo', "");
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => HomePage(prefs: widget.prefs)));
          }).catchError((e) {
            print(e);
          });
        } else {
          print("################# Doc exists");
          await widget.prefs.setBool('is_verified', true).then((value) {
            print("is_verified");
          });
          widget.prefs.setString(
            'mobile',
            phoneNo.phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''),
          );
          userRef.get().then((value) {
            print("profile_photo: ${value.get("profile_photo")}");
            widget.prefs.setString('name', value.get("name").toString());
            widget.prefs.setString('profile_photo', value.get("profile_photo"));
          });
          print("############# pref done ");
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(prefs: widget.prefs),
            ),
          );
        }
      }).catchError((e) {});
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {});
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneNo = number;
                  setState(() {
                    inputLength = controller.text.replaceAll(" ", "").length;
                  });
                },
                maxLength: 12,
                onInputValidated: (bool value) {},
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(),
                initialValue: phoneNo,
                errorMessage: "Wrong Phone number",
                textFieldController: controller,
                formatInput: true,
                autoFocus: true,
                inputDecoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Phone number",
                    labelStyle: TextStyle(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide()),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                    )),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: false),
                onSaved: (PhoneNumber number) {},
              ),
            ),
            (inputError
                ? Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  )
                : Container()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("${inputLength}/9"),
                ],
              ),
            ),
            SizedBox(
              height: 60,
            ),
            GestureDetector(
              onTap: () {
                print("########## ${phoneNo.phoneNumber}");
                if (inputLength == 9) {
                  setState(() {
                    inputError = false;
                    isLoading = true;
                  });
                  // verifyPhone();
                  signIn();
                } else {
                  setState(() {
                    inputError = true;
                  });
                }
              },
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Center(
                      child: !isLoading
                          ? Text(
                              'Verify',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400),
                            )
                          : CircularProgressIndicator(
                              color: Colors.white,
                            ))),
            )
          ],
        ),
      ),
    );
  }
}

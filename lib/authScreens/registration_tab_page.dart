import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';
import '../splashScreen/my_splash_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_dialog.dart';

class RegistrationTabPage extends StatefulWidget {
  const RegistrationTabPage({Key? key}) : super(key: key);

  @override
  State<RegistrationTabPage> createState() => _RegistrationTabPageState();
}

class _RegistrationTabPageState extends State<RegistrationTabPage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String downloadUrlImage = '';

  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();

  getImageFromGallery() async {
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imgXFile;
    });
  }

  formValidation() async {
    if (imgXFile == null) {
      Fluttertoast.showToast(msg: 'Please select an image.');
    } else
    // image selected
    {
      // password is equal to confirm passwordrd
      if (passwordTextEditingController.text ==
          confirmPasswordTextEditingController.text) {
        // check email, password, confirmpassword and name text fields
        if (nameTextEditingController.text.isNotEmpty &&
            emailTextEditingController.text.isNotEmpty &&
            passwordTextEditingController.text.isNotEmpty &&
            confirmPasswordTextEditingController.text.isNotEmpty &&
            phoneTextEditingController.text.isNotEmpty &&
            locationTextEditingController.text.isNotEmpty) {
          // loading...
          showDialog(
              context: context,
              builder: (c) {
                return LoadingDialogWidget(message: 'Registering your account');
              });

          // upload image to storage
          // za dodjeljivanje imena slici koja se snima koristimo vrijeme (u sString)
          String fileName = DateTime.now().microsecondsSinceEpoch.toString();
          fStorage.Reference storageRef = fStorage.FirebaseStorage.instance
              .ref()
              .child('sellersImages')
              .child(fileName);

          fStorage.UploadTask uploadImageTask =
              storageRef.putFile(File(imgXFile!.path));

          fStorage.TaskSnapshot taskSnapshot =
              await uploadImageTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((urlImage) {
            // dodjeljujemo url (string) slike iz storaga
            downloadUrlImage = urlImage;
          });

          // save the user info to firestore database
          saveInformationToDatabase();
          // on complete
          Fluttertoast.showToast(msg: 'Sign Up successfully.');
        } else {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: 'Please complete the form. Do not leave text fields empty.');
        }
      } else {
        // password is not equal to confirm passeord
        Fluttertoast.showToast(
            msg: 'Password and Confirm Password are not equal.');
      }
    }
  }

  saveInformationToDatabase() async {
    //authenticate the user
    User? currentUser;
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim())
        .then((auth) {
      currentUser = auth.user;
    }).catchError((errorMessage) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Error Occurred: \n $errorMessage');
    });

    if (currentUser != null) {
      // save info to database and locally
      saveInfoFirestoreAndLocal(currentUser!);
    }
  }

  saveInfoFirestoreAndLocal(User currentUser) async {
    //to firestore
    FirebaseFirestore.instance.collection('sellers').doc(currentUser.uid).set({
      'uid': currentUser.uid,
      'email': currentUser.email,
      'name': nameTextEditingController.text.trim(),
      'photoUrl': downloadUrlImage,
      'phone': phoneTextEditingController.text.trim(),
      'address': locationTextEditingController.text.trim(),
      'status': 'approved',
      'earnings': 0.0,
    });
    // locally save with sharedPreferences
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString('uid', currentUser.uid);
    await sharedPreferences!.setString('email', currentUser.email!);
    await sharedPreferences!
        .setString('name', nameTextEditingController.text.trim());
    await sharedPreferences!.setString('photoUrl', downloadUrlImage);

    Navigator.push(
        context, MaterialPageRoute(builder: (c) => MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Container(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // get capture image

            GestureDetector(
              onTap: () {
                getImageFromGallery();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage:
                    imgXFile == null ? null : FileImage(File(imgXFile!.path)),
                child: imgXFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        color: Colors.grey,
                        size: MediaQuery.of(context).size.width * 0.20,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            //input field
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    textEditingController: nameTextEditingController,
                    iconData: Icons.person,
                    hintText: 'Name',
                    isObsecure: false,
                    enabled: true,
                  ),
                  CustomTextField(
                    textEditingController: emailTextEditingController,
                    iconData: Icons.email,
                    hintText: 'Email',
                    isObsecure: false,
                    enabled: true,
                  ),
                  CustomTextField(
                    textEditingController: passwordTextEditingController,
                    iconData: Icons.lock,
                    hintText: 'Password',
                    isObsecure: true,
                    enabled: true,
                  ),
                  CustomTextField(
                    textEditingController: confirmPasswordTextEditingController,
                    iconData: Icons.lock,
                    hintText: 'Confirm Password',
                    isObsecure: true,
                    enabled: true,
                  ),
                  // phone
                  CustomTextField(
                    textEditingController: phoneTextEditingController,
                    iconData: Icons.phone,
                    hintText: 'Phone',
                    isObsecure: false,
                    enabled: true,
                  ),
                  // location
                  CustomTextField(
                    textEditingController: locationTextEditingController,
                    iconData: Icons.location_city,
                    hintText: 'Address',
                    isObsecure: false,
                    enabled: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              onPressed: () {
                formValidation();
              },
              child: const Text(
                'Sign Up',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

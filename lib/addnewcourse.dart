import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddNewCourse extends StatefulWidget {
  const AddNewCourse({Key? key}) : super(key: key);

  @override
  State<AddNewCourse> createState() => _AddNewCourseState();
}

class _AddNewCourseState extends State<AddNewCourse> {
  TextEditingController _courseTitle = TextEditingController();
  TextEditingController _courseDescription = TextEditingController();
  String? imgUrl;
  XFile? img;
  chooseImage() async {
    final ImagePicker _imgPicker = ImagePicker();
    img = await _imgPicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  writeData() async {
    try {
      File imgFile = File(img!.path);
      FirebaseStorage _storage = FirebaseStorage.instance;
      UploadTask _uploadTask =
          _storage.ref("images").child(img!.name).putFile(imgFile);
      TaskSnapshot _snapShot = await _uploadTask;
      imgUrl = await _snapShot.ref.getDownloadURL();
      print(imgUrl);
      CollectionReference _coures = FirebaseFirestore.instance.collection("Courses");
      _coures.add({
        "courseTitle" : _courseTitle.text,
        "courseDescription" : _courseDescription.text,
        "imageUrl":imgUrl
      });
      print("succesfully added");
      Navigator.pop(context);
       
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller:_courseTitle ,
              decoration: InputDecoration(
                hintText: "Enter Your Title",
              ),
            ),
            TextField(
              controller: _courseDescription,
              decoration: InputDecoration(
                hintText: "Enter Your Description",
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: Material(
                    child: img == null
                        ? IconButton(
                            onPressed: () => chooseImage(),
                            icon: Icon(
                              Icons.image_rounded,
                              size: 40,
                            ),
                          )
                        : Image.file(
                            File(img!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => writeData(),
              child: Text("Add This Course"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateCourse extends StatefulWidget {
  String documentId;
  String title;
  String details;
  String img;

  UpdateCourse(this.documentId, this.title, this.details, this.img);

  @override
  State<UpdateCourse> createState() => _UpdateCourseState();
}

class _UpdateCourseState extends State<UpdateCourse> {
  TextEditingController _courseTitle = TextEditingController();
  TextEditingController _courseDescription = TextEditingController();
  String? imgUrl;
  XFile? img;
  chooseImage() async {
    final ImagePicker _imgPicker = ImagePicker();
    img = await _imgPicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

 updateData(documentId) async {
    if(img==null){
      CollectionReference _coures =
      FirebaseFirestore.instance.collection("Courses");
      _coures.doc(documentId).update({
        "courseTitle": _courseTitle.text,
        "courseDescription": _courseDescription.text,
        "imageUrl": widget.img
      });
      print("succesfully added");
      Navigator.pop(context);
    }
    else{
      try {
        File imgFile = File(img!.path);
        FirebaseStorage _storage = FirebaseStorage.instance;
        UploadTask _uploadTask =
        _storage.ref("images").child(img!.name).putFile(imgFile);
        TaskSnapshot _snapShot = await _uploadTask;
        imgUrl = await _snapShot.ref.getDownloadURL();
        print(imgUrl);
        CollectionReference _coures =
        FirebaseFirestore.instance.collection("Courses");
        _coures.doc(documentId).update({
          "courseTitle": _courseTitle.text,
          "courseDescription": _courseDescription.text,
          "imageUrl": imgUrl
        });
        print("succesfully added");
        Navigator.pop(context);
      } catch (e) {
        print(e);
      }
    }

  }

  @override
  void initState() {
    super.initState();
    _courseTitle.text = widget.title;
    _courseDescription.text = widget.details;
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
              controller: _courseTitle,
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
                        ? Stack(
                            children: [
                              Container(
                                width: double.maxFinite,
                                child: Image.network(
                                  widget.img,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Positioned(
                                left: 20,
                                top: 10,
                                child: CircleAvatar(
                                  child: InkWell(
                                      onTap: ()=>chooseImage(),
                                      child: Icon(Icons.image_rounded)),
                                ),
                              )
                            ],
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
              onPressed: () => updateData(widget.documentId),
              child: Text("Update This Course"),
            ),
          ],
        ),
      ),
    );
  }
}

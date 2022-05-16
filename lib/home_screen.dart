import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/signinscreen.dart';
import 'package:crud/updatecourse.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'addnewcourse.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  Future signUp(email, pass) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      var authCredential = credential.user;
      if (authCredential!.uid.isNotEmpty) {
        return Navigator.push(
            context, CupertinoPageRoute(builder: (context) => SignInScreen()));
      } else {
        print("something goes Wrong");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  addnewCourse() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => AddNewCourse(),
    );
  }
  Future <void> updateACourse(selectedDocument,title,details,img){
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => UpdateCourse(selectedDocument,title,details,img),
    );
  }

  Future<void> deleteCourse(selectedDocument) {
    return FirebaseFirestore.instance
        .collection("Courses")
        .doc(selectedDocument)
        .delete()
        .then((value) => print("course has been deleted"))
      .catchError((error) => print(error));
  }

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('Courses').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrangeAccent,
          title: Text("Crud Operation"),
          centerTitle: true,
          actions: [
            GestureDetector(
                onTap: () => addnewCourse(), child: Icon(Icons.add)),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Stack(
                      children: [
                        Card(
                          child: Container(
                            child: Container(
                              height: 200,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                        width: double.maxFinite,
                                        child: Image.network(
                                          data["imageUrl"],
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                  Text(
                                    data["courseTitle"],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    data["courseDescription"],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              color: Colors.white70,
                              height: 60,
                              width: 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      updateACourse(document.id,data["courseTitle"],data["courseDescription"],data["imageUrl"]);
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      deleteCourse(document.id);
                                    },
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                            ))
                      ],
                    ),
                  );
                }).toList(),
              );
            }));
  }
}

// Container(
// child: Column(
// children: [
// Container(
// child: Column(
// children: [
// TextField(
// controller: _emailController,
// decoration: InputDecoration(
// hintText: "Enter your email",
// ),
// ),
// SizedBox(
// height: 10,
// ),
// TextField(
// controller: _passController,
// decoration: InputDecoration(
// hintText: "Enter your Password",
// ),
// ),
// SizedBox(height: 10,),
// ElevatedButton(onPressed: (){
// final email = _emailController.text;
// final pass = _passController.text;
// signUp(email, pass);
// }, child: Text("SignUP")),
// ],
// ),
// ),
// SizedBox(height: 50,),
//
//
//
//
// ],
// ),
// )

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationtracker/pages/groups/groups.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SignuppageState createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.title)), body: Forms());
  }
}

class Forms extends StatefulWidget {
  const Forms({Key? key}) : super(key: key);

  @override
  _FormsState createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  TextEditingController usernameEditingController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();

  bool isloading = false;
  final keys = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Container(
      child: Center(child: CircularProgressIndicator()),
    )
        : Form(
        key: keys,
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: (Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email",
                    icon: Icon(Icons.email)),
                validator: (value) {
                  return RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value!)
                      ? null
                      : "Please Enter Correct Email";
                },
                controller: emailEditingController,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: "Enter your name",
                    labelText: "Name",
                    icon: Icon(Icons.book)),
                validator: (value) {
                  return value!.length > 3
                      ? null
                      : "Name must be of 3+ characters";
                },
                controller: usernameEditingController,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: "Enter your password",
                    labelText: "Password",
                    icon: Icon(Icons.lock)),
                validator: (value) {
                  return value!.length > 6
                      ? null
                      : "Enter Password 6+ characters";
                },
                controller: passwordEditingController,
              ),
              ElevatedButton(
                child: Text("Register"),
                onPressed: () {
                  signUp();
                },
              ),
            ],
          )),
        ));
  }

  signUp() async {
    if (keys.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: emailEditingController.text,
            password: passwordEditingController.text);

        await dbadd(userCredential);
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Signup successful')));
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => Groups(username:'')
            )
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          isloading = false;
        });
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Password too weak')));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Email already in use')));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error $e')));
        }
      } catch (e) {
        print(e);
      }
    }
  }
  List setSearchParam(String searchedtext) {
    List<String> caseSearchList = <String>[];
    String temp = "";
    for (int i = 0; i < searchedtext.length; i++) {
      temp = temp + searchedtext[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  Future<void> dbadd(UserCredential userCredential) async {
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    Map<String, dynamic> mapuser = {
      'name': usernameEditingController.text,
      'searchname':setSearchParam(usernameEditingController.text),
      'email': userCredential.user.email.toString(),
    };
    users
        .doc(userCredential.user.uid.toString())
        .set(mapuser)
        .then((value) => print("User added"))
        .catchError((error) => print("Failed to adduser: $error"));
  }
}

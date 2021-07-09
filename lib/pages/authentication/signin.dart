
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:locationtracker/constants/constants.dart';
import 'package:locationtracker/helpers/sharedpref.dart';
import 'package:locationtracker/pages/groups/groups.dart';

class Signinpage extends StatefulWidget {
  const Signinpage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SigninpageState createState() => _SigninpageState();
}

class _SigninpageState extends State<Signinpage> {
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
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  sharedpref sf = new sharedpref();
  bool _isloading = false;
  late String _username;
  final keys = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _isloading
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
              GestureDetector(
                onTap: () {},
                child: Container(
                    child: Text(
                      "Forgot Password?",
                    )),
              ),
              ElevatedButton(
                  child: Text("Log In"),
                  // splashColor: Colors.red,
                  onPressed: () {
                    signIn();
                  }),
            ],
          )),
        ));
  }

  signIn() async {
    if (keys.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: emailEditingController.text,
            password: passwordEditingController.text);
        await addshared_pref();
        setState(() {
          _isloading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logged in successfully')));
        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => Groups(username:sf.getUsername().toString())
            )
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No user found for that email.')));
          setState(() {
            _isloading = false;
          });
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Wrong password provided for that user.')));
          setState(() {
            _isloading = false;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error $e')));
          setState(() {
            _isloading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isloading = false;
        });
        print(e);
      }
    }
  }

  Future<void> addshared_pref() async {

    FirebaseFirestore.instance.collection('users').where(
        'email', isEqualTo: emailEditingController.text).get().then((
        snapshot) async {
      snapshot.docs.forEach((element) async {
        await sf.saveUsername(element['name']);
        _username=element['name'];
        print(element['name']);
      });
    });

  }
}

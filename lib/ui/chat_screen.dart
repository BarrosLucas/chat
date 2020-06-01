import 'dart:io';

import 'package:chat/ui/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  Future<FirebaseUser> _getUser() async{
    if(_currentUser!=null){
      return _currentUser;
    }
    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.getCredential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(authCredential);

      final FirebaseUser user = authResult.user;

      return user;
    }catch(error){
      return null;
    }
  }


  void _sendMessage({String text, PickedFile file}) async{
    final FirebaseUser user = await _getUser();

    if(user == null){
      _key.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível fazer o login"),
        backgroundColor: Colors.red,
      ));
    }

    Map<String,dynamic> map = {
      "uid":user.uid,
      "senderName":user.displayName,
      "senderPhoto":user.photoUrl
    };
    if (file != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(File(file.path));
      StorageTaskSnapshot snapshot = await task.onComplete;
      String url = await snapshot.ref.getDownloadURL();
      map['imageURL'] = url;
      print(url);
    }
    if(text != null){
      map['text']=text;
    }
    Firestore.instance.collection("messages").add(map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Usuario"),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('messages').snapshots(),
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> docs = snapshot.data.documents;
                      return ListView.builder(itemCount: docs.length,reverse: true,itemBuilder: (contex,index){
                        return ListTile(
                          title: Text(docs[index].data['text']),
                        );
                      },);
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextComposer(_sendMessage),
          )
        ],
      ),
    );
  }



  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _currentUser = user;
    });
  }
}

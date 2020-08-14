import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/pages/home.dart';
import 'package:instagram_clone/widgets/custom_image.dart';

import 'package:instagram_clone/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController displaynameController = new TextEditingController();
  TextEditingController bioController = new TextEditingController();
  bool isloading = false;
  User user;
  bool _username = true;
  bool _displayname = true;
  bool _bio = true;
  bool isuploading = true;
  File file;

  String postId = Uuid().v4();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuser();
  }

  getuser() async {
    setState(() {
      isloading = true;
    });

    DocumentSnapshot doc = await usersRef.document(currentUser.id).get();

    user = User.fromDocument(doc);
    usernameController.text = user.username;
    displaynameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isloading = false;
    });
  }

  Column buildusernamefield() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'username',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
              hintText: 'Update Username',
              errorText: _username ? null : 'please Add suitable username'),
        )
      ],
    );
  }

  builddisplayfield() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'displayname',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displaynameController,
          decoration: InputDecoration(
              hintText: 'Update DisplayName',
              errorText:
                  _displayname ? null : 'please Add suitable DisplayName'),
        )
      ],
    );
  }

  buildbioefield() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'username',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
              hintText: 'Add bio',
              errorText: _bio ? null : 'please Add suitable bio'),
        )
      ],
    );
  }

  updateprofiledata() async {
    setState(() {
      usernameController.text.trim().length < 3 ||
              usernameController.text.trim().isEmpty
          ? _username = false
          : _username = true;
      displaynameController.text.trim().length < 3 ||
              displaynameController.text.trim().isEmpty ||
              displaynameController.text.trim().length > 15
          ? _displayname = false
          : _displayname = true;
      bioController.text.trim().length < 3 ||
              bioController.text.trim().isEmpty ||
              bioController.text.trim().length > 20
          ? _bio = false
          : _bio = true;
    });

    if (_username && _displayname && _bio) {
      await addimage();
      usersRef.document(widget.currentUserId).updateData({
        'username': usernameController.text,
        'displayName': displaynameController.text,
        'bio': bioController.text
      });

      SnackBar snackbar = SnackBar(content: Text('Profile Updated'));
      _scaffoldkey.currentState.showSnackBar(snackbar);
    }
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  compressimage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  updatephotourlinfirestor({String mediaUrl}) {
    usersRef.document(widget.currentUserId).updateData({'photoUrl': mediaUrl});
  }

  addimage() async {
    setState(() {
      isuploading = false;
    });
    await compressimage();
    String mediaUrl = await uploadImage(file);

    updatephotourlinfirestor(
      mediaUrl: mediaUrl,
    );
    setState(() {
      isuploading = true;
      postId = Uuid().v4();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      body: isloading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                isuploading ? Text('') : linearProgress(),
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                        child: CircleAvatar(
                            radius: 50,
                            backgroundImage: file == null
                                ? NetworkImage(user.photoUrl)
                                : FileImage(file)),
                      ),
                      FlatButton.icon(
                          onPressed: () => selectImage(context),
                          icon: Icon(Icons.add),
                          label: Text('Add Profile Image')),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            buildusernamefield(),
                            builddisplayfield(),
                            buildbioefield()
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed:
                            isuploading ? () => updateprofiledata() : null,
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

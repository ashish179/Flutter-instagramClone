import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/pages/edit_profile.dart';
import 'package:instagram_clone/pages/home.dart';
import 'package:instagram_clone/widgets/post.dart';
import 'package:instagram_clone/widgets/post_tile.dart';

import 'package:instagram_clone/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileid;
  Profile({this.profileid});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    getProfilePost();
  }

  final String currentuserid = currentUser?.id;
  bool isLoading = false;
  bool isFollowing = false;
  int postCount = 0;
  List<Post> posts = [];
  String postorieantation = 'grid';

  getProfilePost() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot snapshot = await postref
        .document(widget.profileid)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildprofileheader() {
    return FutureBuilder(
        future: usersRef.document(widget.profileid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal,
                      child: CircleAvatar(
                        radius: 47,
                        foregroundColor: Colors.blue,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                buildcountcolum('posts', postCount),
                                buildcountcolum('followers', 0),
                                buildcountcolum('following', 0),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[buildProfileButton()],
                            ),
                          ],
                        ))
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12, left: 10),
                  child: Text(
                    user.username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3, left: 10),
                  child: Text(
                    user.displayName,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3, left: 10),
                  child: Text(
                    user.bio,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        });
  }

  editprofile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentuserid)));
  }

  buildbutton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
          onPressed: function,
          child: Container(
              alignment: Alignment.center,
              width: 240,
              height: 27,
              decoration: BoxDecoration(
                  color: isFollowing ? Colors.white : Colors.blue,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                text,
                style: TextStyle(
                    color: isFollowing ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold),
              ))),
    );
  }

  buildProfileButton() {
    bool isprofileOwner = currentuserid == widget.profileid;

    if (isprofileOwner) {
      return buildbutton(text: 'Edit Profile', function: editprofile);
    } else if (isFollowing) {
      return buildbutton(text: 'Unfollow', function: handleUnfollow);
    } else if (!isFollowing) {
      return buildbutton(text: 'Follow', function: handlefollow);
    }
  }

  handleUnfollow() {
    setState(() {
      isFollowing = false;
    });
    followerRef
        .document(widget.profileid)
        .collection('userFollowers')
        .document(currentuserid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    followingRef
        .document(currentuserid)
        .collection('userFollowing')
        .document(widget.profileid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    activityFeedRef
        .document(widget.profileid)
        .collection('feedItems')
        .document(currentuserid)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  handlefollow() {
    setState(() {
      isFollowing = true;
    });
    followerRef
        .document(widget.profileid)
        .collection('userFollowers')
        .document(currentuserid)
        .setData({});

    followingRef
        .document(currentuserid)
        .collection('userFollowing')
        .document(widget.profileid)
        .setData({});

    activityFeedRef
        .document(widget.profileid)
        .collection('feedItems')
        .document(currentuserid)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileid,
      'username': currentUser.username,
      'userId': currentuserid,
      'userProfileImage': currentUser.photoUrl,
      'timestamp': timestamp
    });
  }

  Column buildcountcolum(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(count.toString(),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey[800],
                fontSize: 15,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  buildProfilePost() {
    if (isLoading) {
      return circularProgress();
    } else if (postorieantation == 'grid') {
      List<GridTile> gridtile = [];

      posts.forEach((post) {
        gridtile.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridtile,
      );
    } else if (postorieantation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setpostorientation(String orientation) {
    setState(() {
      this.postorieantation = orientation;
    });
  }

  buildTogglePost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          onPressed: () => setpostorientation('grid'),
          color: postorieantation == 'grid' ? Colors.black : Colors.grey,
        ),
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () => setpostorientation('list'),
          color: postorieantation == 'list' ? Colors.black : Colors.grey,
        )
      ],
    );
  }

  Container buildSplashScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 10),
            child: Text(
              'You Not Posted Anything !',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          SvgPicture.asset('assets/images/no_content.svg', height: 120.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.blue,
          title: Text(
            'Profile',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            DropdownButton(
              underline: Container(),
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.exit_to_app),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                  value: 'logout',
                ),
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'logout') {
                  googleSignIn.signOut();
                }
              },
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            buildprofileheader(),
            buildTogglePost(),
            Divider(),
            postCount == 0 ? buildSplashScreen() : buildProfilePost()
          ],
        ));
  }
}

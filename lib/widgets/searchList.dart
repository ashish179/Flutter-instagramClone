import 'package:flutter/material.dart';
import 'package:instagram_clone/pages/activity_feed.dart';

// ignore: must_be_immutable
class SearchListWidget extends StatefulWidget {
  final String username;
  final String displayname;
  final String image;
  final String id;

  SearchListWidget(this.username, this.displayname, this.image, this.id);

  @override
  _SearchListWidgetState createState() => _SearchListWidgetState();
}

class _SearchListWidgetState extends State<SearchListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => showProfile(context, profileId: widget.id),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.image),
              radius: 30,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      widget.displayname,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.verified_user,
                      color: Colors.blue,
                    )
                  ],
                ),
                Text(widget.username)
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

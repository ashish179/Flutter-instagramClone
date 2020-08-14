import 'package:flutter/material.dart';
import 'package:instagram_clone/pages/post_screen.dart';
import 'package:instagram_clone/widgets/custom_image.dart';
import 'package:instagram_clone/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    showPost(context) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostScreen(
                    postId: post.postId,
                    userId: post.ownerId,
                  )));
    }

    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:instagram_clone/pages/home.dart';

import 'package:instagram_clone/widgets/searchList.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _form = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();
  QuerySnapshot searchResultsFuture;

  var username;
  Future<void> handleSearch() async {
    final _isvalid = _form.currentState.validate();

    FocusScope.of(context).unfocus();

    if (_isvalid) {
      await usersRef
          .where("username", isGreaterThanOrEqualTo: username)
          .getDocuments()
          .then((value) {
        setState(() {
          searchResultsFuture = value;
        });
      });

      print(searchResultsFuture);
    }
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Form(
        key: _form,
        child: TextFormField(
          controller: searchController,
          validator: (value) {
            if (value.isEmpty) {
              return 'enter the user';
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search for a user...",
            filled: true,
            prefixIcon: Icon(
              Icons.account_circle,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: handleSearch,
            ),
          ),
          onSaved: (newValue) {
            setState(() {
              username = newValue;
            });
          },
        ),
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset(
              'assets/images/pexels-photo2.jpeg',
              height: orientation == Orientation.landscape ? 300 : 600,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: searchResultsFuture.documents.length,
          itemBuilder: (context, i) => SearchListWidget(
                searchResultsFuture.documents[i].data['username'],
                searchResultsFuture.documents[i].data['displayName'],
                searchResultsFuture.documents[i].data['photoUrl'],
                searchResultsFuture.documents[i].data['id'],
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

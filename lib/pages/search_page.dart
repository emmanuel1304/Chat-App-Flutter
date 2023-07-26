import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textEditingController = TextEditingController();
  QuerySnapshot? searchSnapshot;
  bool isLoading = false;
  bool hasUserSearched = false;
  String? userName = "";
  bool isInGroup = false;

  @override
  initState() {
    super.initState();
    getUserName();
  }

  getUserName() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        userName = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            cursorColor: Colors.white,
            cursorWidth: 4,
            style: const TextStyle(color: Colors.white),
            controller: textEditingController,
            decoration: const InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await initiateSearch();
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : groupList());
  }

  initiateSearch() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await DataBaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
            .searchFunction(textEditingController.text);
    setState(() {
      searchSnapshot = snapshot;
      isLoading = false;
      hasUserSearched = true;
    });
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              String groupName = searchSnapshot!.docs[index]['groupName'];
              String groupId = searchSnapshot!.docs[index]['groupID'];
              checkUserInGroup(searchSnapshot!.docs[index]['groupID'],
                  searchSnapshot!.docs[index]['groupName']);
              return ListTile(
                title: Text(groupName),
                subtitle: Text(groupId),
                trailing: isInGroup
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: () {},
                        child: const Text(
                          "Joined",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: () async {
                          await DataBaseServices(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .joinGroup(groupId, groupName)
                              .whenComplete(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                      grouName: groupName,
                                      groupId: groupId,
                                      ),
                                ));
                          });
                        },
                        child: const Text(
                          "Join Now",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              );
            },
          )
        : Container();
  }

  checkUserInGroup(String groupId, String groupName) async {
    bool? result =
        await DataBaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
            .checkUser(groupId, groupName);
    setState(() {
      isInGroup = result!;
    });
  }
}

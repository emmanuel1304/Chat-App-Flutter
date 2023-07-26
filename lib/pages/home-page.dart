import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/shared_preferences/shared_preferences.dart';
import 'package:chat_app/widgets/grouptile.dart';
import 'package:chat_app/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../widgets/nogroup_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "";
  String email = "";
  AuthService authService = AuthService();
  HelperFunctions helperFunctions = HelperFunctions();
  Stream? groups;
  bool isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    getUserName();
    getUserEmail();
    getUserGroups();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  getUserName() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        username = value!;
      });
    });
  }

  getUserEmail() async {
    await HelperFunctions.getUserEmail().then((value) {
      setState(() {
        email = value!;
      });
    });
  }

  getUserGroups() async {
    await DataBaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshots) {
      setState(() {
        groups = snapshots;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Groups",
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ));
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      drawer: Drawer(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 5, right: 5, top: 50, bottom: 50),
          child: ListView(
            children: [
              const Icon(
                Icons.account_circle,
                size: 150,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(username,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                height: 2,
              ),
              ListTile(
                onTap: () {},
                selected: true,
                selectedColor: Theme.of(context).primaryColor,
                contentPadding: const EdgeInsets.only(
                    left: 20, right: 20, top: 5, bottom: 5),
                leading: const Icon(Icons.group),
                title: const Text(
                  "Groups",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ));
                },
                selected: false,
                selectedColor: Theme.of(context).primaryColor,
                contentPadding: const EdgeInsets.only(
                    left: 20, right: 20, top: 5, bottom: 5),
                leading: const Icon(Icons.person_2),
                title: const Text(
                  "Profile",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ListTile(
                onTap: () async {
                  await authService.logUserOut().whenComplete(() {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                  });
                },
                selected: false,
                selectedColor: Theme.of(context).primaryColor,
                contentPadding: const EdgeInsets.only(
                    left: 20, right: 20, top: 5, bottom: 5),
                leading: const Icon(Icons.exit_to_app),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        onPressed: () {
          popUpDialogue(context);
        },
        child: const Icon(Icons.add),
      ),
      body: groupList(),
    );
  }

  popUpDialogue(BuildContext context) {
    showDialog(
        //barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                "Create A New Group",
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : TextField(
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          onChanged: (val) {
                            setState(() {
                              groupName = val;
                            });
                          },
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      setState(() {
                        isLoading = true;
                      });
                      DataBaseServices(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(groupName, username)
                          .whenComplete(() {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pop(context);
                        showSnackBar(
                            context,
                            "Successfully Created Group $groupName",
                            Colors.green);
                      });
                    }
                  },
                  child: const Text("Create"),
                )
              ],
            );
          });
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTileWidget(
                      userName: snapshot.data['fullName'],
                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]));
                },
              );
            } else {
              return const Center(
                child: NoGroupWidget(),
              );
            }
          } else {
            return const Center(child: NoGroupWidget());
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }
}

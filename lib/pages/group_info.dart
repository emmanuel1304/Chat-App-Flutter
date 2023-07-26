import 'package:chat_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class GroupInfo extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String adminName;

  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? stream;

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  @override
  void initState() {
    super.initState();
    getGroupInfo();
  }

  getGroupInfo() async {
    await DataBaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupInfo(widget.groupId)
        .then((snapshot) {
      setState(() {
        stream = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: stream,
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data['members'].length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text(
                      "${widget.groupName}'s Info",
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 15,),

                    
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(getName(snapshot.data['members'][index])
                            .substring(0, 1)
                            .toUpperCase()),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }
        }),
      ),
    );
  }
}

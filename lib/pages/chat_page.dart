import 'package:chat_app/pages/group_info.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String grouName;

  const ChatPage({
    super.key,
    required this.grouName,
    required this.groupId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = "";
  Stream<QuerySnapshot>? chat;
  String message = "";
  bool isLoading = false;
  final TextEditingController messageController = TextEditingController();

  @override
  initState() {
    super.initState();
    getChat();
  }

  getChat() async {
    await DataBaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getMessages(widget.groupId)
        .then((snapshot) {
      setState(() {
        chat = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.grouName),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupInfo(
                          groupId: widget.groupId,
                          groupName: widget.grouName,
                          adminName: admin),
                    ));
              },
              icon: const Icon(Icons.info),
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                        hintText: "Send Message...",
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue))),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: () async {
                      await DataBaseServices(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .sendMessage(widget.groupId, messageController.text);
                      messageController.text = "";
                    },
                    icon: const Icon(Icons.send),
                  ),
                )
              ],
            ),
          ),
        ),
        body: StreamBuilder(
          stream: chat,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data.docs.length != 0){ 
                List<DocumentSnapshot> messageDocs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: messageDocs.length,
                itemBuilder: (context, index) {
                  String messageText = messageDocs[index]['message'];
                  String sender = messageDocs[index]['sender'];
                  String? user = messageDocs[index]['user'];
                  bool currentUser =
                      FirebaseAuth.instance.currentUser!.uid == sender;
                  return Column(
                    crossAxisAlignment: currentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      currentUser
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 20, bottom: 20, right: 14),
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 10, right: 10),
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 1, 75, 136),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))),
                              child: Column(
                                children: [
                                  Text(
                                    messageText,
                                    
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    user!,
                                    
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                  
                                ],
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(
                                  top: 20, bottom: 20, left: 14),
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 10, right: 10),
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 1, 75, 136),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  )),
                              child: Column(
                                children: [
                                  Text(
                                    messageText,
                                    
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    user!,
                                    
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  );
                },
              );
              } else { 
                return const Center(child: Text("No Messages", style: TextStyle(fontSize: 30, color: Colors.grey),));
              }
            } else {
              return const Center(child: Text("No Messages", style: TextStyle(fontSize: 30, color: Colors.grey),));
            }
          },
        ));
  }
}

import 'package:chat_app/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class GroupTileWidget extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupTileWidget(
      {super.key,
      required this.userName,
      required this.groupId,
      required this.groupName});

  @override
  State<GroupTileWidget> createState() => _GroupTileWidgetState();
}

class _GroupTileWidgetState extends State<GroupTileWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    grouName: widget.groupName,
                    groupId: widget.groupId,
                    )));
      },
      child: InkWell(
        child: ListTile(
          title: Text(widget.groupName),
          subtitle: Text("Join The Conversation As ${widget.userName}"),
          leading: CircleAvatar(
            child: Text(widget.groupName.substring(0, 1).toUpperCase()),
          ),
        ),
      ),
    );
  }
}

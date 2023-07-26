import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseServices {
  final String? uid;

  DataBaseServices({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("user");

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  //saving user data to firestore
  Future savingUserData(String fullName, String email) async {
    return await userCollection
        .doc(uid)
        .set({"fullName": fullName, "email": email, "groups": [], "id": uid});
  }

  //checking if user email exist
  Future getUserEmail(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  //getting user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  Future createGroup(String groupName, String userName) async {
    DocumentReference documentReference = await groupCollection.add({
      "groupName": groupName,
      "admin": "${uid}_$userName",
      "members": [],
      "groupID": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    //update the new document member list with the user that created it.
    await documentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupID": documentReference.id,
    });

    DocumentReference userDocumentReference = await userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${documentReference.id}_$groupName"])
    });
  }

  getGroupInfo(String id) async {
    DocumentReference documentReference = await groupCollection.doc(id);
    return documentReference.snapshots();
  }

  Future sendMessage(
    String groupId,
    String message,
  ) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userCollection.doc(uid).get();
    String userName = await documentSnapshot['fullName'];
    CollectionReference collectionReference =
        await documentReference.collection('messages');
    collectionReference.add({
      "sender": uid,
      "message": message,
      "user": userName,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future getMessages(String groupId) async {
    CollectionReference collectionReference =
        await groupCollection.doc(groupId).collection('messages');
    return collectionReference.orderBy('timestamp').snapshots();
  }

  searchFunction(String groupName) async {
    QuerySnapshot snapshot =
        await groupCollection.where('groupName', isEqualTo: groupName).get();
    return snapshot;
  }

  Future<bool?> checkUser(String groupId, String groupName) async {
    DocumentReference documentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await documentReference.get();

    List<dynamic> groups = documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  joinGroup(String groupId, String groupName) async {
    DocumentReference documentReference = await userCollection.doc(uid);
    return await documentReference.update({ 
      "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
    });
  }
}

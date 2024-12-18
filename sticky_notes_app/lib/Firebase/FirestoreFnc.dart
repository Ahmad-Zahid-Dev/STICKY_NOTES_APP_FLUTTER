/*import 'package:cloud_firestore/cloud_firestore.dart';


class Firestorefnc {
  final _fire = FirebaseFirestore.instance;
  Future<void> ADD(String title, String description) async {
    try {
      await _fire
          .collection('user1')
          .add({ // Auto-generate document ID
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp() // Add timestamp for sorting
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

// in this we can read whole docs. only for that i have to make a 
 //  Docs class to take input of docs from user


/*UPDATE( user)async{
  try{
    await _fire
    .collection("users")
    .doc("ip6HeGd9PsoMkSbVCbPB")
    .update({"name":user.name , "email": user.email ,"phone": user.phone });

  }catch(e){
    log(e.toString() as num);
  }
}

// in this we can delete whole docs. only for that i have to make a 
 //  Docs class to take input of docs from user

DELETE( docs)  async{
  try{
   await _fire.collection("users").doc(docs.doc).delete();
  }catch(e){
    log(e.toString() as num);
  }*/*/

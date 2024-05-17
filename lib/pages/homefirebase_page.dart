import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:praktikum_app/services/firestore.dart';

class HomeFirebasePage extends StatefulWidget {
  const HomeFirebasePage({super.key});

  @override
  State<HomeFirebasePage> createState() => _HomeFirebasePageState();
}

class _HomeFirebasePageState extends State<HomeFirebasePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textEditingController = TextEditingController();

  //open a dialog
  void openDialog({String? docId}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: textEditingController,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (docId == null) {
                  firestoreService.addNote(textEditingController.text);
                } else {
                  firestoreService.updateNote(
                      docId, textEditingController.text);
                }

                // clear text editing controller
                textEditingController.clear();

                // pop
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: StreamBuilder(
        stream: firestoreService.getNoteStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            //display
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get
                DocumentSnapshot document = notesList[index];

                String docId = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String noteText = data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          openDialog(docId: docId);
                        },
                        icon: const Icon(Icons.settings),
                      ),
                      IconButton(
                        onPressed: () {
                          firestoreService.deleteNote(docId);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text('tidak ada notes');
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:war_20212239/db_helper/db_helper.dart';
import 'package:war_20212239/modal_class/notes.dart';
import 'package:war_20212239/screens/note_list.dart';
import 'package:war_20212239/utils/widgets.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail(this.note, this.appBarTitle, {required Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(note, appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  int color;
  bool isEdited = false;

  NoteDetailState(this.note, this.appBarTitle) : color = 0;

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionController.text = note.description;
    color = note.color;
    return WillPopScope(
        onWillPop: () async {
          isEdited ? showDiscardDialog(context) : moveToLastScreen();
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(
                appBarTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              backgroundColor: colors[color],
              leading: IconButton(
                  splashRadius: 22,
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    isEdited ? showDiscardDialog(context) : moveToLastScreen();
                  }),
              actions: <Widget>[
                IconButton(
                  splashRadius: 22,
                  icon: const Icon(
                    Icons.save,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    titleController.text.isEmpty
                        ? showEmptyTitleDialog(context)
                        : _save();
                  },
                ),
                IconButton(
                  splashRadius: 22,
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    showDeleteDialog(context);
                  },
                )
              ],
            ),
            body: Container(
              color: colors[color],
              child: Column(
                children: <Widget>[
                  PriorityPicker(
                    key: UniqueKey(), // Otra opción podría ser GlobalKey()
                    selectedIndex: 3 - note.priority,
                    onTap: (index) {
                      isEdited = true;
                      note.priority = 3 - index;
                    },
                  ),
                  ColorPicker(
                    key: GlobalKey(), // Puedes usar GlobalKey o UniqueKey
                    selectedIndex: note.color,
                    onTap: (index) {
                      setState(() {
                        color = index;
                      });
                      isEdited = true;
                      note.color = index;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: titleController,
                      maxLength: 255,
                      style: Theme.of(context).textTheme.bodyText2,
                      onChanged: (value) {
                        updateTitle();
                      },
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Titulo',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 10,
                        maxLength: 255,
                        controller: descriptionController,
                        style: Theme.of(context).textTheme.bodyText1,
                        onChanged: (value) {
                          updateDescription();
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Descripción',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: 'cameraButton', // Asigna un heroTag único
                  onPressed: () {
                    //TODO: Lógica para el botón de la cámara de fotos
                  },
                  tooltip: 'Tomar Foto',
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.black, width: 2.0)),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.camera, color: Colors.black),
                ),
                const SizedBox(height: 16.0),
                FloatingActionButton(
                  heroTag: 'micButton',
                  onPressed: () {
                    ///TODO: Lógica para el botón de grabar voz
                  },
                  tooltip: 'Grabar Voz',
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.black, width: 2.0)),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.mic_rounded, color: Colors.black),
                ),
              ],
            )));
  }

  void showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Descartar Cambios?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("¿Estás seguro de que deseas descartar los cambios?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text("No",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Si",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                moveToLastScreen();
              },
            ),
          ],
        );
      },
    );
  }

  void showEmptyTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "El titulo de tu vivencia esta vacio!",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text('El título de la vivencia de hoy no puede estar vacío.',
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text("Entendido",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Deseas eliminar la vivencia?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("¿Estás seguro de que deseas eliminar esta vivencia?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text("No",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Si",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                _delete();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    isEdited = true;
    note.title = titleController.text;
  }

  void updateDescription() {
    isEdited = true;
    note.description = descriptionController.text;
  }

  void _save() async {
    // ...
    // ignore: unnecessary_null_comparison
    if (note.id != null) {
      await helper.updateNote(note);
    } else {
      var result = await helper.insertNote(note);
      print('Note inserted successfully with id: $result');

      // Actualizar la lista en NoteList
      NoteListState().updateListView();
    }
  }

  void _delete() async {
    await helper.deleteNote(note.id);
    moveToLastScreen();
  }
}

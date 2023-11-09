import 'package:flutter/material.dart';
import 'package:war_20212239/db_helper/db_helper.dart';
import 'package:war_20212239/modal_class/notes.dart';
import 'package:war_20212239/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:war_20212239/screens/search_note.dart';
import 'package:war_20212239/utils/widgets.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList = [];

  int count = 0;
  int axisCount = 2;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget myAppBar() {
      return AppBar(
          title: Text('3ra. Guerra Mundial 🪖',
              style: Theme.of(context).textTheme.headlineSmall),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: noteList.isEmpty
              ? Container()
              : IconButton(
                  splashRadius: 22,
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    final Note? result = await showSearch(
                        context: context,
                        delegate: NotesSearch(notes: noteList));
                    if (result != null) {
                      navigateToDetail(result, 'Editar Vivencia');
                    }
                  },
                ),
          actions: <Widget>[
            noteList.isEmpty
                ? Container()
                : IconButton(
                    splashRadius: 22,
                    icon: Icon(
                      axisCount == 2 ? Icons.list : Icons.grid_on,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        axisCount = axisCount == 2 ? 4 : 2;
                      });
                    },
                  ),
            noteList.isEmpty
                ? Container()
                : IconButton(
                    splashRadius: 22,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      showDeleteAllDialog(
                          context); // Función para confirmar la eliminación de todas las notas
                    },
                  ),
          ]);
    }

    return Scaffold(
      appBar: myAppBar(),
      body: noteList.isEmpty
          ? Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'Haz clic en el botón de agregar para añadir una nueva vivencia.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            )
          : Container(
              color: Colors.white,
              child: getNotesList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 3, 0), 'Añadir Vivencia');
        },
        tooltip: 'Añadir Vivencia',
        shape: const CircleBorder(
            side: BorderSide(color: Colors.black, width: 2.0)),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget getNotesList() {
    return StaggeredGridView.countBuilder(
      physics: const BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(noteList[index], 'Editar Vivencia');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: colors[noteList[index].color],
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          noteList[index].title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    Text(
                      getPriorityText(noteList[index].priority),
                      style: TextStyle(
                          color: getPriorityColor(noteList[index].priority)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(noteList[index].description,
                            style: Theme.of(context).textTheme.bodyMedium),
                      )
                    ],
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(noteList[index].date,
                          style: Theme.of(context).textTheme.titleSmall),
                    ])
              ],
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      default:
        return Colors.yellow;
    }
  }

  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '!!!';
      case 2:
        return '!!';
      case 3:
        return '!';
      default:
        return '!';
    }
  }

  void navigateToDetail(Note note, String title) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetail(note, title, key: GlobalKey()),
      ),
    );

    if (result == true) {
      updateListView();
    }
  }

  showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Estás en peligro! Eliminar Todas las vivencias"),
          content: const Text(
              "¿Estás seguro de que deseas eliminar todas las Vivencias?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Eliminar"),
              onPressed: () {
                deleteAllNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteAllNotes() async {
    await databaseHelper.deleteAllNotes();
    updateListView();
  }

  void updateListView() async {
    noteList = await databaseHelper.getNoteList();
    setState(() {
      count = noteList.length;
    });
  }
}

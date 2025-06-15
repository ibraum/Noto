import 'package:Noto/models/note.dart';
import 'package:Noto/services/database_manager.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DatabaseManager dbManager = DatabaseManager();
  List<Note> notes = [];
  final _textController = TextEditingController();
  final _prioriteController = TextEditingController();
  final _progressionController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;

  @override
  void initState() {
    super.initState();
    _chargerNotes();
  }

  Future<void> _chargerNotes() async {
    final list = await dbManager.getAllNotes();
    setState(() {
      notes = list;
    });
  }

  Future<void> _ajouterNote() async {
    final note = Note.sansId(
      text: _textController.text,
      priorite: _prioriteController.text,
      dateDebut: _dateDebut ?? DateTime.now(),
      dateFin: _dateFin ?? DateTime.now(),
      progression: int.tryParse(_progressionController.text) ?? 0,
    );

    await dbManager.insertNote(note);
    _clearNoteForm();
    await _chargerNotes();
  }

  Future<void> _mettreAJourNote(int id) async {
    final note = Note.sansId(
      text: _textController.text,
      priorite: _prioriteController.text,
      dateDebut: _dateDebut ?? DateTime.now(),
      dateFin: _dateFin ?? DateTime.now(),
      progression: int.tryParse(_progressionController.text) ?? 0,
    );

    await dbManager.updateNote(note, id);
    _clearNoteForm();
    await _chargerNotes();
  }

  Future<void> _supprimerNote(int? id) async {
    if (id == null) return;
    await dbManager.deleteNote(id);
    await _chargerNotes();
  }

  void _clearNoteForm() {
    _textController.clear();
    _prioriteController.clear();
    _progressionController.clear();
    _dateDebut = null;
    _dateFin = null;
  }

  void ajouterNote(dynamic context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Ajouter une note",
      barrierColor: Colors.black.withAlpha((0.5 * 255).toInt()),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: AjouterNoteForm(
                  onAdd: (newNote) async {
                    await dbManager.insertNote(newNote);
                    await _chargerNotes();
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
    );
  }

  void modifierNote(dynamic context, Note note) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Modifier la note",
      barrierColor: Colors.black.withAlpha((0.5 * 255).toInt()),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: MiseAJourNoteForm(
                  note: note,
                  onUpdate: (updatedNote) async {
                    await dbManager.updateNote(updatedNote, note.id!);
                    await _chargerNotes();
                  },
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Logo en haut
            Container(
              height: 80,
              width: 50,
              padding: EdgeInsets.only(top: 25),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Image(
                  image: AssetImage("assets/images/notes.png"),
                  width: 35,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Input ajout note
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.all(Radius.circular(60)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Ajouter une note...",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black,
                    ),
                    child: IconButton(
                      onPressed: () {
                        ajouterNote(context);
                      },
                      icon: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            notes.isEmpty
                ? const Text(
                  "Aucune note trouvée. 😣",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                )
                : Column(
                  children:
                      notes
                          .map((note) => buildNoteCard(context, note))
                          .toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget buildNoteCard(BuildContext context, Note note) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notes",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            note.text,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 12),
          Text("Progression", style: TextStyle(fontSize: 12)),
          SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 140,
                child: LinearProgressIndicator(
                  value: note.progression / 100,
                  color: Colors.black,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              SizedBox(width: 8),
              Text("${note.progression}%", style: TextStyle(fontSize: 12)),
            ],
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16),
              SizedBox(width: 6),
              Text(
                DateFormat('d MMM yyyy', 'fr_FR').format(note.dateDebut!),
                style: TextStyle(fontSize: 11),
              ),
              SizedBox(width: 10),
              Icon(Icons.flag, size: 16),
              SizedBox(width: 6),
              Text(
                DateFormat('d MMM yyyy', 'fr_FR').format(note.dateFin!),
                style: TextStyle(fontSize: 11),
              ),
              Spacer(),
            ],
          ),

          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    margin: EdgeInsets.only(left: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        modifierNote(context, note);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: CircleBorder(),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: Icon(Icons.edit, size: 20, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    width: 35,
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        _confirmerSuppressionNote(note.id, context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: CircleBorder(),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: Icon(Icons.delete, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),

              Container(
                decoration: BoxDecoration(
                  color: getPriorityBackground(note.priorite), // Couleur pâle
                  border: Border.all(
                    color: getPriorityColor(note.priorite), // Couleur vive
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Text(
                  note.priorite,
                  style: TextStyle(
                    color: getPriorityColor(
                      note.priorite,
                    ), // Texte en couleur vive
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return Colors.redAccent;
      case 'moyenne':
        return Colors.orangeAccent;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getPriorityBackground(String priority) {
    switch (priority.toLowerCase()) {
      case 'haute':
        return Colors.redAccent.withOpacity(0.1);
      case 'moyenne':
        return Colors.orange.withOpacity(0.1);
      case 'basse':
        return Colors.green.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  void _confirmerSuppressionNote(int? id, BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3), // assombrit le fond
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 👈 effet blur ici
          child: AlertDialog(
            title: const Text(
              'Supprimer la note',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            content: Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.black),
                  ),
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _supprimerNote(id);
                  await _chargerNotes();
                },
                child: const Text('Supprimer'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

class AjouterNoteForm extends StatefulWidget {
  final Function(Note)? onAdd;

  const AjouterNoteForm({Key? key, this.onAdd}) : super(key: key);

  @override
  State<AjouterNoteForm> createState() => _AjouterNoteFormState();
}

class _AjouterNoteFormState extends State<AjouterNoteForm> {
  final _formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final progressionController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String? _priorite;
  final List<String> _priorites = ['Haute', 'Moyenne', 'Basse'];

  Future<void> _selectDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  void _valider() {
    if (_formKey.currentState!.validate()) {
      if (_dateDebut != null &&
          _dateFin != null &&
          _dateDebut!.isAfter(_dateFin!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("La date de début doit être avant la date de fin"),
          ),
        );
        return;
      }

      final newNote = Note.sansId(
        text: noteController.text,
        progression: int.parse(progressionController.text),
        dateDebut: _dateDebut ?? DateTime.now(),
        dateFin: _dateFin ?? DateTime.now(),
        priorite: _priorite ?? 'Moyenne',
      );

      if (widget.onAdd != null) {
        widget.onAdd!(newNote);
      }
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Ajouter la note",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: noteController,
                decoration: _inputDecoration("Entrer une note"),
                validator:
                    (val) => val == null || val.isEmpty ? "Champ requis" : null,
              ),
              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _priorite,
                decoration: _inputDecoration("Priorité"),
                items:
                    _priorites
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                onChanged: (val) => setState(() => _priorite = val),
                validator:
                    (val) => val == null ? "Sélectionner une priorité" : null,
              ),
              SizedBox(height: 15),

              // Date debut
              InkWell(
                onTap: () => _selectDate(true),
                child: InputDecorator(
                  decoration: _inputDecoration("Date de début"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateDebut != null
                            ? DateFormat('yyyy-MM-dd').format(_dateDebut!)
                            : "Date de début",
                        style: TextStyle(
                          color:
                              _dateDebut != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      Icon(Icons.calendar_month, size: 20, color: Colors.black),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Date fin
              InkWell(
                onTap: () => _selectDate(false),
                child: InputDecorator(
                  decoration: _inputDecoration("Date de fin"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateFin != null
                            ? DateFormat('yyyy-MM-dd').format(_dateFin!)
                            : "Date de fin",
                        style: TextStyle(
                          color: _dateFin != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      Icon(Icons.calendar_month, size: 20, color: Colors.black),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: progressionController,
                decoration: _inputDecoration("Progression (0 - 100)"),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final n = int.tryParse(val ?? '');
                  if (n == null || n < 0 || n > 100) {
                    return "Entrez une valeur entre 0 et 100";
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 125,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.black),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Annuler"),
                    ),
                  ),
                  SizedBox(
                    width: 125,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.black),
                      ),
                      onPressed: _valider,
                      child: Text("Ajouter"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    progressionController.dispose();
    super.dispose();
  }
}

class MiseAJourNoteForm extends StatefulWidget {
  final Note note;
  final void Function(Note updatedNote)? onUpdate;

  MiseAJourNoteForm({Key? key, required this.note, this.onUpdate})
    : super(key: key);

  @override
  State<MiseAJourNoteForm> createState() => _MiseAJourNoteFormState();
}

class _MiseAJourNoteFormState extends State<MiseAJourNoteForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController noteController;
  late TextEditingController progressionController;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String? _priorite;
  final List<String> _priorites = ['Haute', 'Moyenne', 'Basse'];

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.note.text);
    progressionController = TextEditingController(
      text: widget.note.progression.toString(),
    );
    _dateDebut = widget.note.dateDebut;
    _dateFin = widget.note.dateFin;
    _priorite = widget.note.priorite;
  }

  @override
  void dispose() {
    noteController.dispose();
    progressionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isDebut
              ? (_dateDebut ?? DateTime.now())
              : (_dateFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  void _valider() {
    if (_formKey.currentState!.validate()) {
      if (_dateDebut != null &&
          _dateFin != null &&
          _dateDebut!.isAfter(_dateFin!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("La date de début doit être avant la date de fin"),
          ),
        );
        return;
      }
      final updatedNote = widget.note.copyWith(
        text: noteController.text,
        priorite: _priorite!,
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        progression: int.parse(progressionController.text),
      );
      if (widget.onUpdate != null) widget.onUpdate!(updatedNote);
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Modifier la note",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: noteController,
                decoration: _inputDecoration("Entrer une note"),
                validator:
                    (val) => val == null || val.isEmpty ? "Champ requis" : null,
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _priorite,
                decoration: _inputDecoration("Priorité"),
                items:
                    _priorites
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                onChanged: (val) => setState(() => _priorite = val),
                validator:
                    (val) => val == null ? "Sélectionner une priorité" : null,
              ),
              SizedBox(height: 15),
              InkWell(
                onTap: () => _selectDate(true),
                child: InputDecorator(
                  decoration: _inputDecoration("Date de début"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateDebut != null
                            ? DateFormat('yyyy-MM-dd').format(_dateDebut!)
                            : "Date de début",
                        style: TextStyle(
                          color:
                              _dateDebut != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      Icon(Icons.calendar_month, size: 20, color: Colors.black),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              InkWell(
                onTap: () => _selectDate(false),
                child: InputDecorator(
                  decoration: _inputDecoration("Date de fin"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateFin != null
                            ? DateFormat('yyyy-MM-dd').format(_dateFin!)
                            : "Date de fin",
                        style: TextStyle(
                          color: _dateFin != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      Icon(Icons.calendar_month, size: 20, color: Colors.black),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: progressionController,
                decoration: _inputDecoration("Progression (0 - 100)"),
                keyboardType: TextInputType.number,
                validator: (val) {
                  final n = int.tryParse(val ?? '');
                  if (n == null || n < 0 || n > 100) {
                    return "Entrez une valeur entre 0 et 100";
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 125,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.black),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text("Annuler"),
                    ),
                  ),
                  SizedBox(
                    width: 125,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.black),
                      ),
                      onPressed: _valider,
                      child: Text("Modifier"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/movie.dart';
import '../services/database_helper.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie;

  const MovieFormScreen({super.key, this.movie});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper.instance;
  
  late TextEditingController _titleController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;
  
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _yearController = TextEditingController(text: widget.movie?.year.toString() ?? '');
    _genreController = TextEditingController(text: widget.movie?.genre ?? '');
    _imagePath = widget.movie?.imagePath;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy('${dir.path}/$fileName');
      
      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final movie = Movie(
        id: widget.movie?.id,
        title: _titleController.text,
        year: int.parse(_yearController.text),
        genre: _genreController.text,
        imagePath: _imagePath,
      );

      if (widget.movie == null) {
        await _dbHelper.createMovie(movie);
      } else {
        await _dbHelper.updateMovie(movie);
      }

      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Новый фильм' : 'Редактировать'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50),
                            Text('Нажмите, чтобы добавить фото'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Год выпуска', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Введите год' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Жанр', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Введите жанр' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMovie,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
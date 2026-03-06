import 'package:flutter/material.dart';
import 'dart:io';
import '../models/movie.dart';
import '../services/database_helper.dart';
import 'settings_screen.dart';
import 'movie_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _movies = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final movies = await _dbHelper.getMovies();
    setState(() {
      _movies = movies;
    });
  }

  Future<void> _deleteMovie(int id) async {
    await _dbHelper.deleteMovie(id);
    _loadMovies();
  }

  Future<void> _openMovieForm({Movie? movie}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieFormScreen(movie: movie),
      ),
    );

    if (result == true) {
      _loadMovies();
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мини Кинопоиск'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _movies.isEmpty
          ? const Center(child: Text('Список пуст. Добавьте фильм!'))
          : ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: movie.imagePath != null && movie.imagePath!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(movie.imagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => const Icon(Icons.movie),
                            ),
                          )
                        : const Icon(Icons.movie),
                    title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${movie.year} • ${movie.genre}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openMovieForm(movie: movie),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMovie(movie.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openMovieForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
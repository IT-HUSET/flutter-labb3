import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Future<List<Movie>> fetchMovies() async {
  final response = await http
      .get(Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=7a6ee51c10ebca434dab583592d083bf'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return parseMovies(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load movie');
  }
}

// A function that converts a response body into a List<Movie>.
List<Movie> parseMovies(String responseBody) {
  final parsed = jsonDecode(responseBody) as Map<String, dynamic>;
  final list = parsed['results'].cast<Map<String, dynamic>>();

  return list.map<Movie>((json) => Movie.fromJson(json)).toList();
}

class Movie {
  final int id;
  final String title;
  final String posterPath;

  String get posterImageUrl => 'https://image.tmdb.org/t/p/w500/$posterPath';

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['original_title'],
      posterPath: json['poster_path'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Isolate Demo';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Movie>> futureMovie;

  @override
  void initState() {
    super.initState();
    futureMovie = fetchMovies();
  }

  void _refresh() {
    setState(() {
      futureMovie = Future.value([]);
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        futureMovie = fetchMovies();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: futureMovie,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return MovieList(movies: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}


class MovieList extends StatelessWidget {
  const MovieList({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemCount: movies.length, itemBuilder: (context, index) =>
        Row(children: [
            //leading: Image.network(movies[index].posterImageUrl),
            Container(
              width: 80,
              height: 120,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              alignment: Alignment.center,
              child: Image.network(movies[index].posterImageUrl),
            ),
            Text(movies[index].title),
          ]
        ),
      physics: const AlwaysScrollableScrollPhysics(),
        //Image.network(movies[index].posterImageUrl)
    );
  }
}

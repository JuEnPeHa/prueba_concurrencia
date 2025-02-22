import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String URL_COMMENTS = 'https://jsonplaceholder.typicode.com/comments';
const String URL_PHOTOS = 'https://jsonplaceholder.typicode.com/photos';

const List<String> URLS = [URL_COMMENTS, URL_PHOTOS];

class ObtenerDatos extends StatelessWidget {
  const ObtenerDatos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obtener Datos')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final data = await _getData();
                final dataShort = data.take(10).toList();
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Datos'),
                          content: SingleChildScrollView(
                            child: Text(dataShort.join('\n')),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                  );
                }
              },
              child: const Text('Obtener Datos Sin Paralelismo'),
            ),
            ElevatedButton(
              onPressed: () async {
                final data = await _getDataParalel();
                final dataShort = data.take(10).toList();
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Datos'),
                          content: Text(dataShort.join('\n')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                  );
                }
              },
              child: const Text('Obtener Datos Con Paralelismo'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<dynamic>> _getData() async {
  final DateTime inicio = DateTime.now();
  final List<dynamic> data = [];

  for (final url in URLS) {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (url == URL_COMMENTS) {
          final List<Comment> posts = parsearComments(response.body);
          data.addAll(posts.map((e) => e.toString()).toList());
        } else if (url == URL_PHOTOS) {
          final List<dynamic> parsed = jsonDecode(response.body);
          data.addAll(parsed.map((e) => e.toString()).toList());
        }
        print(data);
      } else {
        data.add('Error: ${response.statusCode}');
      }
    } catch (e) {
      data.add('Error: $e');
    }
  }

  final DateTime fin = DateTime.now();

  final int tiempo = fin.difference(inicio).inMilliseconds;

  data.insert(0, 'Tiempo: $tiempo ms');

  return data;
}

Future<List<dynamic>> _getDataParalel() async {
  final DateTime inicio = DateTime.now();
  final List<String> data = [];

  try {
    final responses = await Future.wait(
      URLS.map((url) => http.get(Uri.parse(url))),
    );

    for (final response in responses) {
      if (response.statusCode == 200) {
        if (response.request!.url.toString() == URL_COMMENTS) {
          final List<Comment> posts = parsearComments(response.body);
          data.addAll(posts.map((e) => e.toString()).toList());
        } else if (response.request!.url.toString() == URL_PHOTOS) {
          final List<dynamic> parsed = jsonDecode(response.body);
          data.addAll(parsed.map((e) => e.toString()).toList());
        }
      } else {
        data.add('Error: ${response.statusCode}');
      }
    }
  } catch (e) {
    data.add('Error: $e');
  }

  final DateTime fin = DateTime.now();

  final int tiempo = fin.difference(inicio).inMilliseconds;

  data.insert(0, 'Tiempo: $tiempo ms');

  return data;
}

class Comment {
  int postId;
  int id;
  String name;
  String email;
  String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'],
      id: json['id'],
      name: json['name'],
      email: json['email'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'id': id,
      'name': name,
      'email': email,
      'body': body,
    };
  }

  @override
  String toString() {
    return 'Comment{postId: $postId, id: $id, name: $name, email: $email, body: $body}';
  }
}

List<Comment> parsearComments(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Comment>((json) => Comment.fromJson(json)).toList();
}

class Photos {
  int albumId;
  int id;
  String title;
  String url;
  String thumbnailUrl;

  Photos({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory Photos.fromJson(Map<String, dynamic> json) {
    return Photos(
      albumId: json['albumId'],
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  @override
  String toString() {
    return 'Photos{albumId: $albumId, id: $id, title: $title, url: $url, thumbnailUrl: $thumbnailUrl}';
  }
}

List<Photos> parsearPhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Photos>((json) => Photos.fromJson(json)).toList();
}

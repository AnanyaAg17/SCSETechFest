import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PodcastGenerator(),
    );
  }
}

class PodcastGenerator extends StatefulWidget {
  @override
  _PodcastGeneratorState createState() => _PodcastGeneratorState();
}

class _PodcastGeneratorState extends State<PodcastGenerator> {
  final String newsApiKey = 'ba670b064f62470cadbe6d42ffa83344';
  final String chatGptApiKey =
      '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';
  final String newsApiUrl = 'https://newsapi.org/v2/everything';
  final String chatGptApiUrl = 'https://api.openai.com/v1/chat/completions';
  TextEditingController _textInputController = TextEditingController();
  String podcastSpeech = '';

  Future<List<dynamic>> getNewsContent(String userInput) async {
    final response = await http
        .get(Uri.parse('$newsApiUrl?q=$userInput&apiKey=$newsApiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];
      final List<dynamic> titles =
          articles.take(20).map((article) => article['description']).toList();
      return titles;
    } else {
      throw Exception('Failed to load news');
    }
  }

  Future<String> generatePodcastSpeech(String newsContent) async {
    try {
      final response = await http.post(
        Uri.parse(chatGptApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $chatGptApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {
              'role': 'user',
              'content':
                  'Can generate podcast content regarding the following topic:\n\n$newsContent'
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('API Error: ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to generate podcast speech. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in generatePodcastSpeech: $e');
      throw Exception('Failed to generate podcast speech: $e');
    }
  }

  Future<void> handleUserInput() async {
    final userInput = _textInputController.text;
    final newsContentList = await getNewsContent(userInput);

    if (newsContentList.isNotEmpty) {
      final newsContent = newsContentList.join('\n');
      final podcastSpeech = await generatePodcastSpeech(newsContent);

      setState(() {
        this.podcastSpeech = podcastSpeech;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Podcast Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textInputController,
              decoration: InputDecoration(
                hintText: 'Enter your topic',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: handleUserInput,
              child: Text('Generate Podcast'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  podcastSpeech,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:podcast_generation_website/myCollection.dart';
import 'package:podcast_generation_website/podcastSpeechProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PodcastSpeechProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePageWidget(),
    );
  }
}

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late TextEditingController _textController;
  late FocusNode _textFieldFocusNode;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  final String newsApiKey = 'ba670b064f62470cadbe6d42ffa83344';
  final String chatGptApiKey =
      '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';
  final String newsApiUrl = 'https://newsapi.org/v2/everything';
  final String chatGptApiUrl = 'https://api.openai.com/v1/chat/completions';
  String podcastSpeech = '';

  Future<List<dynamic>> getNewsContent(String userInput) async {
    final response = await http
        .get(Uri.parse('$newsApiUrl?q=$userInput&apiKey=$newsApiKey'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articles = data['articles'];
      final List<dynamic> titles =
          articles.take(100).map((article) => article['description']).toList();
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
                  'Can generate podcast content regarding the following topic:\n\n$newsContent Give a title then generate segments where each segment is separated by a line and each segment has a brief description on what the person should speak followed by pointers. Explain the description and make the description more specific and elaborate in a few lines'
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
    final userInput = _textController.text;
    final newsContentList = await getNewsContent(userInput);

    if (newsContentList.isNotEmpty) {
      final newsContent = newsContentList.join('\n');
      final podcastSpeech = await generatePodcastSpeech(newsContent);

      Provider.of<PodcastSpeechProvider>(context, listen: false)
          .podcastSpeechFuture = Future.value(podcastSpeech);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MyCollectionWidget(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0x9D0299FF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60), // Adjust as needed
              const Text(
                'Turn your thoughts to reality...',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF1B2C71),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 27),
              Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          // Replace with your navigation logic
                          // context.pushNamed('MyCollection');
                        },
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 2),
                          child: TextFormField(
                            controller: _textController,
                            focusNode: _textFieldFocusNode,
                            onFieldSubmitted: (_) async {
                              // Replace with your navigation logic
                              // context.pushNamed('MyCollection');
                            },
                            obscureText: false,
                            decoration: const InputDecoration(
                              hintText:
                                  'Input outline of your podcast content...',
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                            ),
                            validator: (_) {
                              // Add your validation logic if needed
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleUserInput,
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF417AB8),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

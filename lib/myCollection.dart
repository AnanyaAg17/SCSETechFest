import 'package:flutter/material.dart';
import 'package:podcast_generation_website/podcastSpeechProvider.dart';
import 'package:provider/provider.dart';

class MyCollectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PodPilot',
          style: TextStyle(
            fontSize: 20.0, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: FutureBuilder(
                // Access the future from the provider
                future:
                    Provider.of<PodcastSpeechProvider>(context, listen: false)
                        .podcastSpeechFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading content: ${snapshot.error}'),
                    );
                  } else {
                    // Split the content into segments based on the line separator
                    List<String> segments =
                        snapshot.data.toString().split('\n\n');

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (String segment in segments)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    segment,
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  // Add pointers or additional content as needed
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

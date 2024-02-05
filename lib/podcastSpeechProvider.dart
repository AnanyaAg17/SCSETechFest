import 'package:flutter/material.dart';

class PodcastSpeechProvider with ChangeNotifier {
  late Future<String> _podcastSpeechFuture;

  Future<String> get podcastSpeechFuture => _podcastSpeechFuture;

  set podcastSpeechFuture(Future<String> value) {
    _podcastSpeechFuture = value;
    notifyListeners();
  }
}

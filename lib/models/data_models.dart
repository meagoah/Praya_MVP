import 'package:flutter/material.dart';

enum FaithType { universal, christian, muslim, atheist, spiritual }

class FeedItem {
  String id;
  String author;
  String country;
  String originalText;
  String translatedText;
  bool showTranslation;
  int likes;
  bool isLiked;
  bool isSaved;
  bool isHidden;
  List<String> privateNotes;
  Color artSeedColor; // Pro generativní umění

  FeedItem({
    required this.id,
    required this.author,
    required this.country,
    required this.originalText,
    required this.translatedText,
    this.likes = 0,
    this.isLiked = false,
    this.showTranslation = false,
    this.isSaved = false,
    this.isHidden = false,
    List<String>? privateNotes,
    Color? artSeedColor,
  })  : privateNotes = privateNotes ?? [],
        artSeedColor = artSeedColor ?? Colors.blue;
}

class CharityProject {
  String title;
  String description;
  double progress;
  String raised;
  Color color;
  CharityProject(
      this.title, this.description, this.progress, this.raised, this.color);
}

class LevelInfo {
  final String title;
  final String description;
  final String perk;
  LevelInfo(this.title, this.description, this.perk);
}
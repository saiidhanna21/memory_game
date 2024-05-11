import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:memory_game/animation/confetti_animation.dart';
import 'package:memory_game/components/replay_popup.dart';
import 'package:memory_game/components/word_tile.dart';
import 'package:memory_game/main.dart';
import 'package:memory_game/managers/game_manager.dart';
import 'package:memory_game/models/word.dart';
import 'package:memory_game/pages/error_page.dart';
import 'package:memory_game/pages/loading_page.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  final int level;

  const GamePage({Key? key, required this.level}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final _futureCachedImages;
  List<Word> _gridWords = [];
  late int _currentLevel;
  late int _totalPairs; // Variable to track total number of pairs

  @override
  void initState() {
    _futureCachedImages = _cacheImages();
    _currentLevel = widget.level;
    _totalPairs = _getLevelSettings().rows *
        _getLevelSettings().columns; // Calculate total pairs
    _setUp(_getLevelSettings()); // Set up based on selected level
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthPadding = size.width * 0.10;
    return FutureBuilder(
      future: _futureCachedImages,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorPage();
        }
        if (snapshot.hasData) {
          return Selector<GameManager, bool>(
            selector: (_, gameManager) =>
                gameManager.roundCompleted ||
                gameManager.answeredWords.length == _totalPairs,
            builder: (_, __, ___) {
              final gameManager = Provider.of<GameManager>(context);
              final roundCompleted = gameManager.roundCompleted ||
                  gameManager.answeredWords.length == _totalPairs;

              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) async {
                  print('Should show popup: $roundCompleted');
                  if (roundCompleted ||
                      gameManager.answeredWords.length == _totalPairs) {
                    print('Showing replay popup');
                    await showDialog(
                      barrierColor: Colors.transparent,
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const ReplayPopUp(),
                    );
                  }
                },
              );

              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/Cloud.png'),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          left: widthPadding,
                          right: widthPadding,
                        ),
                        itemCount: _gridWords.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getLevelSettings().columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: size.height * 0.38,
                        ),
                        itemBuilder: (context, index) => WordTile(
                          index: index,
                          word: _gridWords[index],
                          onCorrectAnswer: () {
                            print('Correct answer found!');
                          },
                        ),
                      ),
                    ),
                  ),
                  ConfettiAnimation(animate: roundCompleted),
                ],
              );
            },
          );
        } else {
          return const LoadingPage();
        }
      },
    );
  }

  void _setUp(LevelSettings levelSettings) {
    sourceWords.shuffle();
    _gridWords.clear(); // Clear existing grid words

    int totalWords = levelSettings.rows * levelSettings.columns;

    for (int i = 0; i < totalWords ~/ 2; i++) {
      // Add word with text only
      _gridWords.add(Word(
        text: sourceWords[i].text,
        displayText: true,
      ));

      // Add word with encoded image
      _gridWords.add(Word(
        text: sourceWords[i].text,
        url: sourceWords[i].url, // Store the encoded image data
        displayText: false,
      ));
    }

    _gridWords.shuffle();
  }

  Future<int> _cacheImages() async {
    for (var w in _gridWords) {
      if (!w.displayText && w.url != null) {
        try {
          String base64Image = w.url!;
          Uint8List bytes = base64Decode(base64Image);

          // Update the Word object with the decoded image bytes
          w.imageBytes = bytes;
        } catch (e) {
          print('Error decoding image: $e');
        }
      }
    }

    // After decoding all images, return a completed future
    return Future.value(1);
  }

  LevelSettings _getLevelSettings() {
    switch (_currentLevel) {
      case 1:
        return LevelSettings(rows: 2, columns: 3);
      case 2:
        return LevelSettings(rows: 2, columns: 4);
      case 3:
        return LevelSettings(rows: 2, columns: 5);
      default:
        return LevelSettings(rows: 2, columns: 3); // Default to level 1
    }
  }
}

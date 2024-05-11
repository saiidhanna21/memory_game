import 'package:flutter/material.dart';
import 'package:memory_game/managers/audio_manager.dart';
import 'package:memory_game/models/word.dart';

class GameManager extends ChangeNotifier {
  Map<int, Word> tappedWords = {};
  bool canFlip = false,
      reverseFlip = false,
      ignoreTaps = false,
      roundCompleted = false;
  List<int> answeredWords = [];
  late int _totalPairs; // Define totalPairs variable

  GameManager(int totalPairs) {
    _totalPairs = totalPairs;
  }

  tileTapped({required int index, required Word word}) {
    ignoreTaps = true;
    if (tappedWords.length <= 1) {
      tappedWords.addEntries([MapEntry(index, word)]);
      canFlip = true;
    } else {
      canFlip = false;
    }

    notifyListeners(); // Notify listeners after state change
  }

  onAnimationCompleted({required bool isForward}) async {
    if (tappedWords.length == 2) {
      if (isForward) {
        if (tappedWords.entries.elementAt(0).value.text ==
            tappedWords.entries.elementAt(1).value.text) {
          answeredWords.addAll(tappedWords.keys);
          print("pairs $_totalPairs");
          if (answeredWords.length == _totalPairs) {
            print("Equal");
            // Check if all pairs are matched
            await AudioManager.playAudio('Round');
            roundCompleted = true;
          } else {
            await AudioManager.playAudio('Correct');
          }
          tappedWords.clear();
          canFlip = true;
          ignoreTaps = false;
        } else {
          await AudioManager.playAudio('Incorrect');
          reverseFlip = true;
        }
      } else {
        reverseFlip = false;
        tappedWords.clear();
        ignoreTaps = false;
      }
    } else {
      canFlip = false;
      ignoreTaps = false;
    }

    notifyListeners(); // Notify listeners after state change
  }
}

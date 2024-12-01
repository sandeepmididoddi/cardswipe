import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'card_model.dart';

class WalletModel extends ChangeNotifier {
  double balance;
  int points;
  List<CardModel> cards;
  int swipedCards;
  bool isGameActive;

  WalletModel({
    required this.balance, 
    required this.points, 
    required this.cards,
  }) : swipedCards = 0, isGameActive = false;

  void cardSwipedUp() {
    if (!isGameActive) return;
    points += 5;
    swipedCards++;
    
    if (points >= 100) {
      balance += 100.0;
      points = points - 100;
      debugPrint('Added ₹100 to wallet');
    }
    notifyListeners();
  }

  void cardSwipedDown() {
    if (!isGameActive) return;
    if (points >= 10) {
      points -= 10;
      swipedCards++;
      debugPrint('Points after down swipe: $points');
      notifyListeners();
    }
  }

  bool? canSwipeDown() {
    return points >= 10;
  }

  void startGame() {
    isGameActive = true;
    balance = 0.0;
    points = 0;
    swipedCards = 0;
    notifyListeners();
  }

  void resetGame() {
    isGameActive = false;
    balance = 0.0;
    points = 0;
    swipedCards = 0;
    notifyListeners();
  }

  bool isGameCompleted() {
    return swipedCards >= 20;
  }

  void addPoints(int points) {
    this.points += points;
    notifyListeners();
  }

  void addCard(CardModel card) {
    cards.add(card);
    notifyListeners();
  }
}

final walletProvider = ChangeNotifierProvider<WalletModel>((ref) {
  return WalletModel(
    balance: 0.0,
    points: 0,
    cards: [],
  );
});

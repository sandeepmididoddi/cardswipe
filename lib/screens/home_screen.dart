import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'dart:math';
import '../models/wallet_model.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/tutorial_screen.dart';
import '../services/audio_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _checkFirstTimeUser();
    AudioService.initialize();
    AudioService.playBackgroundMusic();
  }

  void _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('firstTime') ?? true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TutorialScreen()),
      );
      await prefs.setBool('firstTime', false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String generateCardNumber() {
    Random random = Random();
    String number = '';
    for (int i = 0; i < 16; i++) {
      if (i > 0 && i % 4 == 0) number += ' ';
      number += random.nextInt(10).toString();
    }
    return number;
  }

  @override
  Widget build(BuildContext context) {
    final walletModel = ref.watch(walletProvider);

    // Check if game is completed
    if (walletModel.isGameCompleted()) {
      return _buildGameCompletedView();
    }

    // If game hasn't started, show start screen
    if (!walletModel.isGameActive) {
      return _buildStartGameView();
    }

    // Main game view
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Card Swipe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(walletProvider.notifier).resetGame();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255).withOpacity(1),
              const Color.fromARGB(255, 40, 41, 41).withOpacity(1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Wallet info at top
            _buildWalletInfoSection(walletModel),
            // Spacer to push cards down
            const Spacer(),
            // Card stack
            _buildCardStack(walletModel),
            // Bottom padding
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStartGameView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255).withOpacity(1),
              const Color.fromARGB(255, 40, 41, 41).withOpacity(1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Card Swipe!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(walletProvider.notifier).startGame();
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Game'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCompletedView() {
    final walletModel = ref.watch(walletProvider);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255).withOpacity(1),
              const Color.fromARGB(255, 40, 41, 41).withOpacity(1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 20),
              Text(
                'Game Completed!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFinalScoreCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Balance',
                    value: '₹${walletModel.balance.toStringAsFixed(2)}',
                  ),
                  const SizedBox(width: 20),
                  _buildFinalScoreCard(
                    icon: Icons.stars,
                    title: 'Points',
                    value: '${walletModel.points}',
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(walletProvider.notifier).resetGame();
                },
                icon: const Icon(Icons.replay),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 20, 20, 20).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfoSection(models.WalletModel walletModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWalletInfo(
            icon: Icons.account_balance_wallet,
            title: 'Balance',
            value: '₹${walletModel.balance.toStringAsFixed(2)}',
          ),
          _buildWalletInfo(
            icon: Icons.stars,
            title: 'Points',
            value: '${walletModel.points}',
          ),
          _buildWalletInfo(
            icon: Icons.credit_card,
            title: 'Cards',
            value: '${walletModel.swipedCards}/20',
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack(models.WalletModel walletModel) {
    final List<Map<String, dynamic>> cards = [
      {
        'name': 'HDFC Bank',
        'color': const Color.fromARGB(255, 4, 134, 241),
        'icon': Icons.account_balance_wallet,
        'number': '01',
        'cardNumber': generateCardNumber(),
      },
      {'name': 'SBI', 'color': const Color.fromARGB(255, 2, 26, 168), 'icon': Icons.currency_rupee, 'number': '02', 'cardNumber': generateCardNumber()},
      {'name': 'ICICI Bank', 'color': Colors.orange, 'icon': Icons.credit_card, 'number': '03', 'cardNumber': generateCardNumber()},
      {'name': 'Axis Bank', 'color': const Color.fromARGB(255, 4, 238, 12), 'icon': Icons.payments, 'number': '04', 'cardNumber': generateCardNumber()},
      {'name': 'Kotak Mahindra Bank', 'color': const Color.fromARGB(255, 201, 4, 236), 'icon': Icons.account_balance, 'number': '05', 'cardNumber': generateCardNumber()},
      {'name': 'RBL Bank', 'color': const Color.fromARGB(255, 239, 22, 6), 'icon': Icons.attach_money, 'number': '06', 'cardNumber': generateCardNumber()},
      {'name': 'IDFC First Bank', 'color': const Color.fromARGB(255, 3, 213, 241), 'icon': Icons.savings, 'number': '07', 'cardNumber': generateCardNumber()},
      {'name': 'Yes Bank', 'color': const Color.fromARGB(255, 222, 7, 79), 'icon': Icons.currency_exchange, 'number': '08', 'cardNumber': generateCardNumber()},
      {'name': 'Bandhan Bank', 'color': const Color.fromARGB(255, 1, 121, 109), 'icon': Icons.monetization_on, 'number': '09', 'cardNumber': generateCardNumber()},
      {'name': 'Union Bank', 'color': const Color.fromARGB(255, 35, 49, 18), 'icon': Icons.account_balance, 'number': '10', 'cardNumber': generateCardNumber()},
      {'name': 'Bank of Baroda', 'color': Colors.deepOrange, 'icon': Icons.account_balance_wallet, 'number': '11', 'cardNumber': generateCardNumber()},
      {'name': 'Punjab National Bank', 'color': Colors.amber, 'icon': Icons.money, 'number': '12', 'cardNumber': generateCardNumber()},
      {'name': 'Central Bank of India', 'color': Colors.blueAccent, 'icon': Icons.account_circle, 'number': '13', 'cardNumber': generateCardNumber()},
      {'name': 'UCO Bank', 'color': Colors.yellow, 'icon': Icons.wallet, 'number': '14', 'cardNumber': generateCardNumber()},
      {'name': 'Canara Bank', 'color': const Color.fromARGB(255, 130, 126, 125), 'icon': Icons.monetization_on, 'number': '15', 'cardNumber': generateCardNumber()},
      {'name': 'Federal Bank', 'color': const Color.fromARGB(255, 99, 21, 234), 'icon': Icons.account_balance_wallet, 'number': '16', 'cardNumber': generateCardNumber()},
      {'name': 'IndusInd Bank', 'color': Colors.lightBlue, 'icon': Icons.attach_money, 'number': '17', 'cardNumber': generateCardNumber()},
      {'name': 'South Indian Bank', 'color': const Color.fromARGB(255, 226, 245, 61), 'icon': Icons.currency_rupee, 'number': '18', 'cardNumber': generateCardNumber()},
      {'name': 'Bank of India', 'color': const Color.fromARGB(255, 76, 251, 166), 'icon': Icons.credit_card, 'number': '19', 'cardNumber': generateCardNumber()},
      {'name': 'City Union Bank', 'color': Colors.orangeAccent, 'icon': Icons.account_balance, 'number': '20', 'cardNumber': generateCardNumber()},
    ];

    return Expanded(
      flex: 4,
      child: Stack(
        alignment: Alignment.center,
        children: cards.asMap().entries.map((entry) {
          return Positioned.fill(
            child: SwipableCard(
              key: ValueKey(entry.value['number']),
              verticalSwipe: true,
              horizontalSwipe: false,
              threshold: 30.0,
              onSwipeUp: (_) {
                walletModel.cardSwipedUp();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle, color: Color.fromARGB(255, 93, 243, 98)),
                        const SizedBox(width: 5),
                        Text(
                          '+5 Points!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color.fromARGB(255, 250, 249, 249),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color.fromARGB(100, 250, 250, 250),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              },
              onSwipeDown: (_) {
                if (walletModel.canSwipeDown() == true) {
                  walletModel.cardSwipedDown();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.remove_circle, color: Colors.red),
                          const SizedBox(width: 5),
                          Text(
                            '-10 Points!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color.fromARGB(255, 250, 249, 249),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color.fromARGB(100, 250, 250, 250),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                } else {
                  setState(() {
                    // Reset card position if needed
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.yellow),
                          const SizedBox(width: 5),
                          Text(
                            'Not enough points! Need 10 points to swipe down.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color.fromARGB(255, 250, 249, 249),
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color.fromARGB(100, 250, 250, 250),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                }
              },
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(30, 5 * _animation.value),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 230,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            entry.value['color'],
                            entry.value['color'].withOpacity(0.95),
                            entry.value['color'].withOpacity(0.95),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      entry.value['icon'],
                                      size: 40,
                                      color: const Color.fromARGB(255, 30, 30, 30),
                                    ),
                                    Text(
                                      entry.value['number'],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: Color.fromARGB(255, 156, 155, 155),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  entry.value['cardNumber'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 30, 30, 30),
                                    letterSpacing: 1,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  entry.value['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 16, 16, 16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList().reversed.toList(),
      ),
    );
  }

  Widget _buildFinalScoreCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SwipableCard extends StatelessWidget {
  final Widget child;
  final bool verticalSwipe;
  final bool horizontalSwipe;
  final double threshold;
  final Function onSwipeUp;
  final Function onSwipeDown;

  const SwipableCard({
    super.key,
    required this.verticalSwipe,
    required this.horizontalSwipe,
    required this.threshold,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Implement your swiping logic here
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -threshold) {
          onSwipeUp();
        } else if (details.primaryVelocity! > threshold) {
          onSwipeDown();
        }
      },
      child: child,
    );
  }
}

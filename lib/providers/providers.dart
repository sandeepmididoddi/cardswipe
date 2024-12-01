import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_model.dart';

final walletProvider = ChangeNotifierProvider<WalletModel>((ref) => WalletModel(
  balance: 0.0,
  points: 0,
  cards: [],
));

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';

class QuizService extends ChangeNotifier {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  List<QuizCategory> _categories = [];
  List<WordPuzzle> _wordPuzzles = [];
  List<MatchFixture> _fixtures = [];
  List<DailyChallenge> _dailyChallenges = [];
  List<LoyaltyReward> _loyaltyStore = [];
  List<FanRank> _fanRanks = [];

  List<QuizCategory> get categories => _categories;
  List<WordPuzzle> get wordPuzzles => _wordPuzzles;
  List<MatchFixture> get fixtures => _fixtures;
  List<DailyChallenge> get dailyChallenges => _dailyChallenges;
  List<LoyaltyReward> get loyaltyStore => _loyaltyStore;
  List<FanRank> get fanRanks => _fanRanks;

  // Persistent User State
  int _coins = 500;
  int _points = 250;
  int _quizzesPlayed = 0;
  int _totalCorrectAnswers = 0;
  int _totalQuestionsAnswered = 0;
  int _wordsSolved = 0;
  int _lifeline5050Count = 1;
  int _extraTimeCount = 1;
  bool _hasVipPass = false;

  Set<String> _claimedDailyChallenges = {};
  final Map<String, String> _matchPredictions = {};
  Set<String> _purchasedRewardIds = {};
  Set<String> _solvedWords = {};

  int get coins => _coins;
  int get points => _points;
  int get quizzesPlayed => _quizzesPlayed;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalQuestionsAnswered => _totalQuestionsAnswered;
  int get wordsSolved => _wordsSolved;
  int get lifeline5050Count => _lifeline5050Count;
  int get extraTimeCount => _extraTimeCount;
  bool get hasVipPass => _hasVipPass;

  Set<String> get claimedDailyChallenges => _claimedDailyChallenges;
  Map<String, String> get matchPredictions => _matchPredictions;
  Set<String> get purchasedRewardIds => _purchasedRewardIds;
  Set<String> get solvedWords => _solvedWords;

  double get accuracyRate {
    if (_totalQuestionsAnswered == 0) return 0.0;
    return (_totalCorrectAnswers / _totalQuestionsAnswered) * 100;
  }

  FanRank get currentRank {
    if (_fanRanks.isEmpty) {
      return FanRank(
        title: 'Club Supporter',
        minPoints: 0,
        badge: 'military_tech',
        perk: 'Standard access',
      );
    }
    FanRank active = _fanRanks.first;
    for (final rank in _fanRanks) {
      if (_points >= rank.minPoints) {
        active = rank;
      }
    }
    return active;
  }

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadQuizDataFromJson();
    await _loadPersistedUserData();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _loadQuizDataFromJson() async {
    try {
      String jsonStr;
      try {
        jsonStr = await rootBundle.loadString('assets/quiz_data.json');
      } catch (_) {
        jsonStr = await rootBundle.loadString('assets/words.json');
      }

      final Map<String, dynamic> data = jsonDecode(jsonStr);

      if (data.containsKey('categories')) {
        _categories = (data['categories'] as List<dynamic>?)
                ?.map((e) => QuizCategory.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }

      if (data.containsKey('word_puzzles')) {
        _wordPuzzles = (data['word_puzzles'] as List<dynamic>?)
                ?.map((e) => WordPuzzle.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }

      if (data.containsKey('match_fixtures')) {
        _fixtures = (data['match_fixtures'] as List<dynamic>?)
                ?.map((e) => MatchFixture.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }

      if (data.containsKey('daily_challenges')) {
        _dailyChallenges = (data['daily_challenges'] as List<dynamic>?)
                ?.map((e) => DailyChallenge.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }

      if (data.containsKey('loyalty_store')) {
        _loyaltyStore = (data['loyalty_store'] as List<dynamic>?)
                ?.map((e) => LoyaltyReward.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }

      if (data.containsKey('fan_ranks')) {
        _fanRanks = (data['fan_ranks'] as List<dynamic>?)
                ?.map((e) => FanRank.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (e) {
      debugPrint('Error loading quiz data from JSON: $e');
    }
  }

  Future<void> _loadPersistedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt('loyalty_coins') ?? 500;
      _points = prefs.getInt('loyalty_points') ?? 250;
      _quizzesPlayed = prefs.getInt('quizzes_played') ?? 0;
      _totalCorrectAnswers = prefs.getInt('total_correct_answers') ?? 0;
      _totalQuestionsAnswered = prefs.getInt('total_questions_answered') ?? 0;
      _wordsSolved = prefs.getInt('words_solved') ?? 0;
      _lifeline5050Count = prefs.getInt('lifeline_5050_count') ?? 1;
      _extraTimeCount = prefs.getInt('extra_time_count') ?? 1;
      _hasVipPass = prefs.getBool('has_vip_pass') ?? false;

      _claimedDailyChallenges =
          (prefs.getStringList('claimed_challenges') ?? []).toSet();
      _purchasedRewardIds =
          (prefs.getStringList('purchased_rewards') ?? []).toSet();
      _solvedWords = (prefs.getStringList('solved_words') ?? []).toSet();

      final predictionPairs = prefs.getStringList('match_predictions') ?? [];
      _matchPredictions.clear();
      for (final pair in predictionPairs) {
        final split = pair.split(':');
        if (split.length == 2) {
          _matchPredictions[split[0]] = split[1];
        }
      }
    } catch (e) {
      debugPrint('Error loading persisted user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('loyalty_coins', _coins);
      await prefs.setInt('loyalty_points', _points);
      await prefs.setInt('quizzes_played', _quizzesPlayed);
      await prefs.setInt('total_correct_answers', _totalCorrectAnswers);
      await prefs.setInt('total_questions_answered', _totalQuestionsAnswered);
      await prefs.setInt('words_solved', _wordsSolved);
      await prefs.setInt('lifeline_5050_count', _lifeline5050Count);
      await prefs.setInt('extra_time_count', _extraTimeCount);
      await prefs.setBool('has_vip_pass', _hasVipPass);

      await prefs.setStringList(
          'claimed_challenges', _claimedDailyChallenges.toList());
      await prefs.setStringList(
          'purchased_rewards', _purchasedRewardIds.toList());
      await prefs.setStringList('solved_words', _solvedWords.toList());

      final predictionList = _matchPredictions.entries
          .map((e) => '${e.key}:${e.value}')
          .toList();
      await prefs.setStringList('match_predictions', predictionList);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> addPoints(int amount) async {
    _points += amount;
    await _saveUserData();
    notifyListeners();
  }

  Future<bool> predictMatch(String fixtureId, String choice, int rewardCoins) async {
    if (_matchPredictions.containsKey(fixtureId)) {
      return false;
    }
    _matchPredictions[fixtureId] = choice;
    _coins += rewardCoins;
    _points += 50;
    await _saveUserData();
    notifyListeners();
    return true;
  }

  Future<void> recordQuizResult({
    required int earnedCoins,
    required int earnedPoints,
    required int correctCount,
    required int totalCount,
  }) async {
    _coins += earnedCoins;
    _points += earnedPoints;
    _quizzesPlayed += 1;
    _totalCorrectAnswers += correctCount;
    _totalQuestionsAnswered += totalCount;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> recordWordSolved(String word, int points) async {
    if (!_solvedWords.contains(word)) {
      _solvedWords.add(word);
      _wordsSolved += 1;
      _coins += points;
      _points += (points * 1.5).round();
      await _saveUserData();
      notifyListeners();
    }
  }

  Future<bool> claimDailyChallenge(String challengeId, int reward) async {
    if (_claimedDailyChallenges.contains(challengeId)) {
      return false;
    }
    _claimedDailyChallenges.add(challengeId);
    _coins += reward;
    _points += 100;
    await _saveUserData();
    notifyListeners();
    return true;
  }

  Future<bool> buyReward(LoyaltyReward reward) async {
    if (_coins < reward.cost) {
      return false;
    }
    _coins -= reward.cost;
    _purchasedRewardIds.add(reward.id);

    if (reward.id == 'reward_lifeline_5050') {
      _lifeline5050Count += 3;
    } else if (reward.id == 'reward_extra_time') {
      _extraTimeCount += 3;
    } else if (reward.id == 'reward_pass_gold') {
      _hasVipPass = true;
      _points += 500;
    } else {
      _points += 200;
    }

    await _saveUserData();
    notifyListeners();
    return true;
  }

  bool useLifeline5050() {
    if (_lifeline5050Count > 0) {
      _lifeline5050Count -= 1;
      _saveUserData();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool useExtraTime() {
    if (_extraTimeCount > 0) {
      _extraTimeCount -= 1;
      _saveUserData();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> resetProgress() async {
    _coins = 500;
    _points = 250;
    _quizzesPlayed = 0;
    _totalCorrectAnswers = 0;
    _totalQuestionsAnswered = 0;
    _wordsSolved = 0;
    _lifeline5050Count = 1;
    _extraTimeCount = 1;
    _hasVipPass = false;
    _claimedDailyChallenges.clear();
    _matchPredictions.clear();
    _purchasedRewardIds.clear();
    _solvedWords.clear();
    await _saveUserData();
    notifyListeners();
  }
}

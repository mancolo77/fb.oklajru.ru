import 'package:flutter/material.dart';

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int points;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correct_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      points: json['points'] as int? ?? 100,
    );
  }
}

class QuizCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String colorHex;
  final List<QuizQuestion> questions;

  QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorHex,
    required this.questions,
  });

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFE21A22);
    }
  }

  IconData get iconData {
    switch (icon) {
      case 'emoji_events':
        return Icons.emoji_events;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'stadium':
        return Icons.stadium;
      case 'military_tech':
        return Icons.military_tech;
      case 'psychology':
        return Icons.psychology;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.sports;
    }
  }

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    final qList = (json['questions'] as List<dynamic>?)
            ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return QuizCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'sports_soccer',
      colorHex: json['color'] as String? ?? '#E21A22',
      questions: qList,
    );
  }
}

class WordPuzzle {
  final String word;
  final String hint;
  final String category;
  final String difficulty;
  final int points;

  WordPuzzle({
    required this.word,
    required this.hint,
    required this.category,
    required this.difficulty,
    required this.points,
  });

  factory WordPuzzle.fromJson(Map<String, dynamic> json) {
    return WordPuzzle(
      word: (json['word'] as String? ?? '').toUpperCase().trim(),
      hint: json['hint'] as String? ?? '',
      category: json['category'] as String? ?? 'Football',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      points: json['points'] as int? ?? 100,
    );
  }
}

class MatchFixture {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String matchName;
  final String stadium;
  final String date;
  final String oddsW1;
  final String oddsX;
  final String oddsW2;
  final int rewardCoins;

  MatchFixture({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchName,
    required this.stadium,
    required this.date,
    required this.oddsW1,
    required this.oddsX,
    required this.oddsW2,
    required this.rewardCoins,
  });

  factory MatchFixture.fromJson(Map<String, dynamic> json) {
    return MatchFixture(
      id: json['id'] as String? ?? '',
      homeTeam: json['home_team'] as String? ?? '',
      awayTeam: json['away_team'] as String? ?? '',
      matchName: json['match_name'] as String? ?? '',
      stadium: json['stadium'] as String? ?? '',
      date: json['date'] as String? ?? '',
      oddsW1: json['odds_w1'] as String? ?? '2.00',
      oddsX: json['odds_x'] as String? ?? '3.20',
      oddsW2: json['odds_w2'] as String? ?? '3.50',
      rewardCoins: json['reward_coins'] as int? ?? 150,
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int rewardCoins;
  final String icon;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.rewardCoins,
    required this.icon,
  });

  IconData get iconData {
    switch (icon) {
      case 'military_tech':
        return Icons.military_tech;
      case 'spellcheck':
        return Icons.spellcheck;
      case 'online_prediction':
        return Icons.online_prediction;
      case 'event_available':
        return Icons.event_available;
      default:
        return Icons.star;
    }
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetCount: json['target_count'] as int? ?? 1,
      rewardCoins: json['reward_coins'] as int? ?? 100,
      icon: json['icon'] as String? ?? 'star',
    );
  }
}

class LoyaltyReward {
  final String id;
  final String title;
  final int cost;
  final String icon;
  final String description;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.cost,
    required this.icon,
    required this.description,
  });

  IconData get iconData {
    switch (icon) {
      case 'verified_user':
        return Icons.verified_user;
      case 'filter_2':
        return Icons.filter_2;
      case 'more_time':
        return Icons.more_time;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'developer_board':
        return Icons.developer_board;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.card_giftcard;
    }
  }

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      cost: json['cost'] as int? ?? 100,
      icon: json['icon'] as String? ?? 'card_giftcard',
      description: json['description'] as String? ?? '',
    );
  }
}

class FanRank {
  final String title;
  final int minPoints;
  final String badge;
  final String perk;

  FanRank({
    required this.title,
    required this.minPoints,
    required this.badge,
    required this.perk,
  });

  IconData get iconData {
    switch (badge) {
      case 'shield':
        return Icons.shield;
      case 'confirmation_number':
        return Icons.confirmation_number;
      case 'analytics':
        return Icons.analytics;
      case 'star':
        return Icons.star;
      case 'military_tech':
      default:
        return Icons.military_tech;
    }
  }

  factory FanRank.fromJson(Map<String, dynamic> json) {
    return FanRank(
      title: json['title'] as String? ?? '',
      minPoints: json['min_points'] as int? ?? 0,
      badge: json['badge'] as String? ?? 'military_tech',
      perk: json['perk'] as String? ?? '',
    );
  }
}

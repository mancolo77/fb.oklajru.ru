import 'package:flutter/material.dart';
import '../../services/user_progress_service.dart';
import '../../theme/app_theme.dart';

class MatchData {
  final String id;
  final String sport;
  final String tournament;
  final String date;
  final String time;
  final String teamA;
  final String teamB;
  final String? score;
  final bool isLive;

  const MatchData({
    required this.id,
    required this.sport,
    required this.tournament,
    required this.date,
    required this.time,
    required this.teamA,
    required this.teamB,
    this.score,
    this.isLive = false,
  });
}

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  final UserProgressService _progress = UserProgressService();
  String _selectedSport = 'Все';
  final List<String> _sports = ['Все', 'Футбол', 'Хоккей', 'Баскетбол'];

  final List<MatchData> _matches = const [
    MatchData(
      id: 'fb_m_1',
      sport: 'Футбол',
      tournament: 'Чемпионат России',
      date: 'Сегодня',
      time: '19:30',
      teamA: 'Зенит',
      teamB: 'Краснодар',
      score: '2 : 2',
      isLive: true,
    ),
    MatchData(
      id: 'fb_m_2',
      sport: 'Хоккей',
      tournament: 'Плей-офф',
      date: 'Сегодня',
      time: '20:15',
      teamA: 'Металлург Мг',
      teamB: 'Локомотив Я',
      score: '1 : 3',
      isLive: false,
    ),
    MatchData(
      id: 'fb_m_3',
      sport: 'Футбол',
      tournament: 'Кубок Лиги',
      date: 'Завтра',
      time: '18:00',
      teamA: 'Динамо',
      teamB: 'Спартак',
      score: null,
      isLive: false,
    ),
    MatchData(
      id: 'fb_m_4',
      sport: 'Баскетбол',
      tournament: 'Единая Лига',
      date: 'Завтра',
      time: '19:00',
      teamA: 'ЦСКА',
      teamB: 'Зенит',
      score: null,
      isLive: false,
    ),
    MatchData(
      id: 'fb_m_5',
      sport: 'Хоккей',
      tournament: 'Регулярный сезон',
      date: 'Вчера',
      time: '19:30',
      teamA: 'СКА',
      teamB: 'Динамо М',
      score: '4 : 2',
      isLive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _matches.where((m) {
      if (_selectedSport == 'Все') return true;
      return m.sport == _selectedSport;
    }).toList();

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Матчи',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeadlines,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text(
                      'Пример',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Расписание встреч и спортивные результаты',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 18),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _sports.map((sport) {
                    final isSelected = _selectedSport == sport;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(sport),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedSport = sport);
                        },
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceCard,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.onPrimary : AppTheme.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // List of matches
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: const [
                      Icon(Icons.sports_rounded, size: 48, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text(
                        'Нет матчей в выбранной категории',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...filtered.map((match) {
                  final isFav = _progress.favoriteMatchIds.contains(match.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(
                        color: match.isLive ? AppTheme.primary : AppTheme.border,
                        width: match.isLive ? 1.5 : 1.0,
                      ),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  match.tournament,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceSmall,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Пример',
                                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                                color: isFav ? AppTheme.primary : AppTheme.textSecondary,
                                size: 22,
                              ),
                              onPressed: () => _progress.toggleFavoriteMatch(match.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                match.teamA,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeadlines,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  if (match.score != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: match.isLive ? AppTheme.primary : AppTheme.surfaceSmall,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        match.score!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: match.isLive ? Colors.white : AppTheme.textHeadlines,
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      match.time,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textHeadlines,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    match.isLive ? 'LIVE' : match.date,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: match.isLive ? AppTheme.primary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                match.teamB,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeadlines,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}


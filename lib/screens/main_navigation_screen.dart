import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';
import 'quiz_play_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final QuizService _quizService = QuizService();
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _quizService.init();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _quizService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              MatchCenterTab(),
              WordArenaTab(),
              DailyChallengesTab(),
              FanClubTab(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(color: AppTheme.surfaceBorder, width: 1),
              ),
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: AppTheme.surface,
                selectedItemColor: AppTheme.primary,
                unselectedItemColor: AppTheme.textMuted,
                selectedLabelStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sports_soccer),
                    activeIcon: Icon(Icons.sports_soccer, color: AppTheme.primary),
                    label: 'Матч-центр',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.spellcheck),
                    activeIcon: Icon(Icons.spellcheck, color: AppTheme.primary),
                    label: 'Арена слов',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.task_alt),
                    activeIcon: Icon(Icons.task_alt, color: AppTheme.primary),
                    label: 'Задания',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shield_outlined),
                    activeIcon: Icon(Icons.shield, color: AppTheme.primary),
                    label: 'Фан-клуб',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// TAB 1: МАТЧ-ЦЕНТР И ВИКТОРИНЫ
// =========================================================================

void _showPointsBalanceDialog(BuildContext context, int coins, int points) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentGold.withAlpha(30),
              border: Border.all(color: AppTheme.accentGold, width: 2),
            ),
            child: const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            'Баланс болельщика',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$coins очков лояльности • $points XP',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentGold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Зарабатывайте очки за верные ответы в викторинах, решение филвордов и точные прогнозы на матчи РПЛ!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Понятно', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

class MatchCenterTab extends StatefulWidget {
  const MatchCenterTab({super.key});

  @override
  State<MatchCenterTab> createState() => _MatchCenterTabState();
}

class _MatchCenterTabState extends State<MatchCenterTab> {
  final QuizService _quizService = QuizService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _quizService,
      builder: (context, _) {
        final categories = _quizService.categories;
        final fixtures = _quizService.fixtures;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withAlpha(30),
              ),
              child: const Icon(Icons.sports_soccer, color: AppTheme.primary, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Матч-Центр РПЛ',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () => _showPointsBalanceDialog(context, _quizService.coins, _quizService.points),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withAlpha(90)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_quizService.coins}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Match Day Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withAlpha(80)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'МАТЧ-ДЕЙ КВИЗ',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, color: AppTheme.accentGold, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              '2x Награды фаната',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Интеллект Российской Премьер-Лиги',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Проверьте тактическую эрудицию, память на культовые дерби и рекорды сезона.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Upcoming Match Center Fixtures Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Матчи лиги',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'Прогноз и награды',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Fixtures list
              ...fixtures.map((fixture) {
                final userPick = _quizService.matchPredictions[fixture.id];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: userPick != null
                          ? AppTheme.secondary.withAlpha(90)
                          : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_outlined, size: 13, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${fixture.matchName} • ${fixture.date}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${fixture.rewardCoins}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fixture.homeTeam,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              'VS',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              fixture.awayTeam,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fixture.stadium,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Prediction Buttons
                      Row(
                        children: [
                          _buildPredictionButton(
                            context: context,
                            fixtureId: fixture.id,
                            label: 'П1 ${fixture.oddsW1}',
                            choiceKey: 'П1',
                            currentPick: userPick,
                            reward: fixture.rewardCoins,
                          ),
                          const SizedBox(width: 6),
                          _buildPredictionButton(
                            context: context,
                            fixtureId: fixture.id,
                            label: 'Ничья ${fixture.oddsX}',
                            choiceKey: 'Х',
                            currentPick: userPick,
                            reward: fixture.rewardCoins,
                          ),
                          const SizedBox(width: 6),
                          _buildPredictionButton(
                            context: context,
                            fixtureId: fixture.id,
                            label: 'П2 ${fixture.oddsW2}',
                            choiceKey: 'П2',
                            currentPick: userPick,
                            reward: fixture.rewardCoins,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Quiz Categories Header
              Text(
                'Категории викторин',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Categories List
              ...categories.map((category) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizPlayScreen(category: category),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: category.color.withAlpha(35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: category.color.withAlpha(90),
                              ),
                            ),
                            child: Icon(
                              category.iconData,
                              color: category.color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  category.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      '${category.questions.length} вопросов',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 11,
                                          color: AppTheme.accentGold,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Бонус монет',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.accentGold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildPredictionButton({
    required BuildContext context,
    required String fixtureId,
    required String label,
    required String choiceKey,
    required String? currentPick,
    required int reward,
  }) {
    final isSelected = (currentPick == choiceKey);
    final isAnySelected = (currentPick != null);

    Color bgColor = AppTheme.surface;
    Color textColor = AppTheme.textPrimary;
    Color borderColor = AppTheme.surfaceBorder;

    if (isSelected) {
      bgColor = AppTheme.secondary.withAlpha(80);
      textColor = Colors.white;
      borderColor = AppTheme.secondary;
    } else if (isAnySelected) {
      textColor = AppTheme.textMuted.withAlpha(150);
      borderColor = AppTheme.surfaceBorder.withAlpha(70);
    }

    return Expanded(
      child: InkWell(
        onTap: () async {
          if (isSelected) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ваш прогноз на этот матч: $choiceKey (+$reward очков)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E2833),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.secondary, width: 1.5),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          if (isAnySelected) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.accentGold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Вы уже выбрали исход "$currentPick" для этого матча',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E2833),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppTheme.accentGold, width: 1.5),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          final messenger = ScaffoldMessenger.of(context);
          await _quizService.predictMatch(fixtureId, choiceKey, reward);
          if (!mounted) return;
          setState(() {});
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Прогноз $choiceKey принят! +$reward очков начислено!',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1E2833),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppTheme.secondary, width: 2),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check_rounded, size: 13, color: AppTheme.secondary),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// TAB 2: АРЕНА СЛОВ (УГАДЫВАНИЕ ФУТБОЛЬНЫХ ТЕРМИНОВ)
// =========================================================================
class WordArenaTab extends StatefulWidget {
  const WordArenaTab({super.key});

  @override
  State<WordArenaTab> createState() => _WordArenaTabState();
}

class _WordArenaTabState extends State<WordArenaTab> {
  final QuizService _quizService = QuizService();
  int _currentWordIndex = 0;
  List<String> _scrambledLetters = [];
  List<int> _selectedIndices = [];
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _setupCurrentWord();
  }

  void _setupCurrentWord() {
    final puzzles = _quizService.wordPuzzles;
    if (puzzles.isEmpty) return;

    final puzzle = puzzles[_currentWordIndex];
    final letters = puzzle.word.split('');
    letters.shuffle();

    setState(() {
      _scrambledLetters = letters;
      _selectedIndices = [];
      _isSuccess = false;
    });
  }

  void _onLetterTapped(int index) {
    if (_selectedIndices.contains(index) || _isSuccess) return;

    setState(() {
      _selectedIndices.add(index);
    });

    final puzzle = _quizService.wordPuzzles[_currentWordIndex];
    final constructedWord =
        _selectedIndices.map((i) => _scrambledLetters[i]).join('');

    if (constructedWord == puzzle.word) {
      setState(() {
        _isSuccess = true;
      });
      _quizService.recordWordSolved(puzzle.word, puzzle.points);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Отлично! Слово «${puzzle.word}» собрано! +${puzzle.points} монет!'),
          backgroundColor: AppTheme.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onRemoveLastLetter() {
    if (_selectedIndices.isNotEmpty && !_isSuccess) {
      setState(() {
        _selectedIndices.removeLast();
      });
    }
  }

  void _onClearAll() {
    if (!_isSuccess) {
      setState(() {
        _selectedIndices.clear();
      });
    }
  }

  void _nextWord() {
    final puzzles = _quizService.wordPuzzles;
    if (_currentWordIndex < puzzles.length - 1) {
      setState(() {
        _currentWordIndex++;
      });
      _setupCurrentWord();
    } else {
      setState(() {
        _currentWordIndex = 0;
      });
      _setupCurrentWord();
    }
  }

  void _prevWord() {
    if (_currentWordIndex > 0) {
      setState(() {
        _currentWordIndex--;
      });
      _setupCurrentWord();
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzles = _quizService.wordPuzzles;
    if (puzzles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Арена слов')),
        body: const Center(child: Text('Загрузка заданий...')),
      );
    }

    final puzzle = puzzles[_currentWordIndex];
    final targetLength = puzzle.word.length;
    final isAlreadySolved = _quizService.solvedWords.contains(puzzle.word);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Арена футбольных слов',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Отгадано терминов: ${_quizService.wordsSolved} из ${puzzles.length}'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppTheme.accentPurple, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${_quizService.wordsSolved}/${puzzles.length}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Word Index & Navigation
              Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    onPressed: _currentWordIndex > 0 ? _prevWord : null,
                    color: AppTheme.primary,
                  ),
                  Expanded(
                    child: Text(
                      'Термин ${_currentWordIndex + 1} из ${puzzles.length}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: _nextWord,
                    color: AppTheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Clue Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            puzzle.category.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${puzzle.points} Монет',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ),
                        if (isAlreadySolved || _isSuccess)
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.secondary, size: 14),
                              SizedBox(width: 3),
                              Text(
                                'РЕШЕНО',
                                style: TextStyle(
                                  color: AppTheme.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Тактическая подсказка:',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      puzzle.hint,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Target Word Slots
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: List.generate(targetLength, (index) {
                  final hasLetter = index < _selectedIndices.length;
                  final letter = hasLetter
                      ? _scrambledLetters[_selectedIndices[index]]
                      : (_isSuccess || isAlreadySolved
                          ? puzzle.word[index]
                          : '');

                  return Container(
                    width: 34,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (_isSuccess || isAlreadySolved)
                          ? AppTheme.secondary.withAlpha(35)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (_isSuccess || isAlreadySolved)
                            ? AppTheme.secondary
                            : (hasLetter ? AppTheme.primary : AppTheme.surfaceBorder),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: (_isSuccess || isAlreadySolved)
                            ? AppTheme.secondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Controls: Backspace & Clear
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: (_selectedIndices.isNotEmpty && !_isSuccess)
                        ? _onRemoveLastLetter
                        : null,
                    icon: const Icon(Icons.backspace_outlined, size: 14),
                    label: const Text('Стереть', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: (_selectedIndices.isNotEmpty && !_isSuccess)
                        ? _onClearAll
                        : null,
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Сбросить', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Available Scrambled Letter Tiles
              Text(
                'Нажимайте буквы, чтобы собрать термин:',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_scrambledLetters.length, (index) {
                  final isUsed = _selectedIndices.contains(index);
                  return InkWell(
                    onTap: isUsed ? null : () => _onLetterTapped(index),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isUsed
                            ? AppTheme.surface.withAlpha(60)
                            : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isUsed
                              ? Colors.transparent
                              : AppTheme.primary.withAlpha(120),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _scrambledLetters[index],
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUsed ? AppTheme.textMuted : AppTheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),

              // Next Term Button
              if (_isSuccess || isAlreadySolved)
                ElevatedButton(
                  onPressed: _nextWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Следующее слово',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// TAB 3: ЗАДАНИЯ И ЕЖЕДНЕВНЫЕ МИССИИ
// =========================================================================
class DailyChallengesTab extends StatelessWidget {
  const DailyChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final quizService = QuizService();
    final challenges = quizService.dailyChallenges;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Ежедневные задания',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Daily Check-in Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.accentGold.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentGold.withAlpha(35),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: AppTheme.accentGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ежедневная отметка',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Бонус за активность фаната',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: quizService.claimedDailyChallenges.contains('daily_fan_attendance')
                          ? null
                          : () async {
                              final ok = await quizService.claimDailyChallenge(
                                  'daily_fan_attendance', 150);
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Бонус посещения получен! +150 монет!'),
                                    backgroundColor: AppTheme.secondary,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: AppTheme.background,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        quizService.claimedDailyChallenges.contains('daily_fan_attendance')
                            ? 'Получено'
                            : 'Забрать 150',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Challenges List Header
              Text(
                'Активные миссии',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              ...challenges.map((challenge) {
                final isClaimed =
                    quizService.claimedDailyChallenges.contains(challenge.id);

                int currentProgress = 0;
                if (challenge.id.contains('quiz')) {
                  currentProgress = quizService.quizzesPlayed;
                } else if (challenge.id.contains('word')) {
                  currentProgress = quizService.wordsSolved;
                } else if (challenge.id.contains('predictor')) {
                  currentProgress = quizService.matchPredictions.length;
                } else {
                  currentProgress = 1;
                }

                final canClaim =
                    !isClaimed && currentProgress >= challenge.targetCount;
                final progressFraction = (currentProgress / challenge.targetCount)
                    .clamp(0.0, 1.0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isClaimed
                          ? AppTheme.surfaceBorder
                          : (canClaim
                              ? AppTheme.primary.withAlpha(120)
                              : AppTheme.surfaceBorder),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              challenge.iconData,
                              color: isClaimed
                                  ? AppTheme.textMuted
                                  : AppTheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  challenge.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isClaimed
                                        ? AppTheme.textSecondary
                                        : AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  challenge.description,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${challenge.rewardCoins}',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressFraction,
                                backgroundColor: AppTheme.surfaceBorder,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isClaimed
                                      ? AppTheme.textMuted
                                      : AppTheme.primary,
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$currentProgress / ${challenge.targetCount}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: canClaim
                              ? () async {
                                  final ok = await quizService.claimDailyChallenge(
                                      challenge.id, challenge.rewardCoins);
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Награда получена! +${challenge.rewardCoins} монет!'),
                                        backgroundColor: AppTheme.secondary,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canClaim
                                ? AppTheme.primary
                                : AppTheme.surfaceBorder,
                            foregroundColor: canClaim
                                ? AppTheme.background
                                : AppTheme.textMuted,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isClaimed ? 'Выполнено' : (canClaim ? 'Забрать награду' : 'В процессе'),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// TAB 4: ФАН-КЛУБ, МАГАЗИН НАГРАД И ПРОФИЛЬ
// =========================================================================
class FanClubTab extends StatelessWidget {
  const FanClubTab({super.key});

  @override
  Widget build(BuildContext context) {
    final quizService = QuizService();
    final rank = quizService.currentRank;
    final storeItems = quizService.loyaltyStore;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Фан-клуб РПЛ',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile & Rank Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: quizService.hasVipPass
                        ? AppTheme.accentGold
                        : AppTheme.primary.withAlpha(100),
                    width: quizService.hasVipPass ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: quizService.hasVipPass
                          ? AppTheme.accentGold.withAlpha(30)
                          : AppTheme.primary.withAlpha(20),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withAlpha(30),
                            border: Border.all(
                              color: quizService.hasVipPass
                                  ? AppTheme.accentGold
                                  : AppTheme.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            rank.iconData,
                            size: 24,
                            color: quizService.hasVipPass
                                ? AppTheme.accentGold
                                : AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      rank.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (quizService.hasVipPass) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: AppTheme.accentGold,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rank.perk,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withAlpha(140),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildProfileStat(
                              title: 'Монеты',
                              value: '${quizService.coins}',
                              icon: Icons.star_rounded,
                              color: AppTheme.accentGold,
                            ),
                          ),
                          Expanded(
                            child: _buildProfileStat(
                              title: 'Опыт XP',
                              value: '${quizService.points}',
                              icon: Icons.star,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                          Expanded(
                            child: _buildProfileStat(
                              title: 'Точность',
                              value: '${quizService.accuracyRate.toStringAsFixed(0)}%',
                              icon: Icons.track_changes,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Loyalty Rewards Shop Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Магазин наград',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Обмен монет',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Store Items
              ...storeItems.map((item) {
                final canAfford = quizService.coins >= item.cost;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.iconData,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: canAfford
                            ? () async {
                                final ok = await quizService.buyReward(item);
                                if (ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Получено: ${item.title}!'),
                                      backgroundColor: AppTheme.secondary,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford
                              ? AppTheme.accentGold
                              : AppTheme.surfaceBorder,
                          foregroundColor: canAfford
                              ? AppTheme.background
                              : AppTheme.textMuted,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              '${item.cost}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Supporter Settings & Reset Options
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.refresh, color: AppTheme.accentRose),
                      title: Text(
                        'Сбросить прогресс',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentRose,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        'Сброс статистики, прогнозов и наград',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          _showResetConfirmDialog(context, quizService);
                        },
                        child: const Text('Сброс', style: TextStyle(color: AppTheme.accentRose, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, QuizService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: Text(
          'Сбросить прогресс?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Все заработанные очки, статистика и награды будут сброшены.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              service.resetProgress();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRose),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

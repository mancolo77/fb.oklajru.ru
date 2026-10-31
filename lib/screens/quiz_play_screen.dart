import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';

class QuizPlayScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizPlayScreen({super.key, required this.category});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final QuizService _quizService = QuizService();

  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  int _score = 0;
  int _correctCount = 0;

  // Lifelines state for current question
  Set<int> _disabledOptionIndices = {};

  // Question Timer
  int _secondsLeft = 25;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 25;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
        if (!_answered) {
          _handleTimeOut();
        }
      }
    });
  }

  void _handleTimeOut() {
    setState(() {
      _answered = true;
      _selectedOptionIndex = -1; // timed out
    });
  }

  void _onOptionSelected(int index) {
    if (_answered || _disabledOptionIndices.contains(index)) return;

    _timer?.cancel();
    final question = widget.category.questions[_currentIndex];
    final isCorrect = (index == question.correctIndex);

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
      if (isCorrect) {
        _score += question.points;
        _correctCount++;
      }
    });
  }

  void _use5050Lifeline() {
    if (_answered) return;
    if (_disabledOptionIndices.isNotEmpty) return;
    if (_quizService.lifeline5050Count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Подсказок 50/50 не осталось! Откройте в Фан-клубе.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = _quizService.useLifeline5050();
    if (success) {
      final question = widget.category.questions[_currentIndex];
      final incorrectIndices = <int>[];
      for (int i = 0; i < question.options.length; i++) {
        if (i != question.correctIndex) {
          incorrectIndices.add(i);
        }
      }
      incorrectIndices.shuffle();
      setState(() {
        _disabledOptionIndices = incorrectIndices.take(2).toSet();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('50/50 активировано! Два неверных варианта убраны.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _useExtraTime() {
    if (_answered) return;
    if (_quizService.extraTimeCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Бустеров времени не осталось! Откройте в Фан-клубе.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = _quizService.useExtraTime();
    if (success) {
      setState(() {
        _secondsLeft += 20;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('+20 секунд добавлено на таймер матча!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextQuestion() {
    if (_currentIndex < widget.category.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOptionIndex = null;
        _disabledOptionIndices.clear();
      });
      _startTimer();
    } else {
      _showResultsDialog();
    }
  }

  void _showResultsDialog() {
    _timer?.cancel();
    final totalQuestions = widget.category.questions.length;
    final coinsEarned = _score;
    final pointsEarned = (_score * 1.2).round();

    _quizService.recordQuizResult(
      earnedCoins: coinsEarned,
      earnedPoints: pointsEarned,
      correctCount: _correctCount,
      totalCount: totalQuestions,
    );

    final percentage =
        totalQuestions > 0 ? ((_correctCount / totalQuestions) * 100).round() : 0;

    String rankVerdict = 'Тактик матч-центра';
    if (percentage == 100) {
      rankVerdict = 'Выдающийся результат!';
    } else if (percentage >= 70) {
      rankVerdict = 'Отличный тактический анализ!';
    } else {
      rankVerdict = 'Продолжайте тренировки!';
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withAlpha(35),
                    boxShadow: AppTheme.neonGlow,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppTheme.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  rankVerdict,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '«${widget.category.title}» завершено',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryStat(
                          label: 'Точность',
                          value: '$percentage%',
                          icon: Icons.track_changes,
                          color: AppTheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryStat(
                          label: 'Монеты',
                          value: '+$coinsEarned',
                          icon: Icons.star_rounded,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryStat(
                          label: 'Опыт XP',
                          value: '+$pointsEarned',
                          icon: Icons.star,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.surfaceBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'В хаб',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _currentIndex = 0;
                            _score = 0;
                            _correctCount = 0;
                            _answered = false;
                            _selectedOptionIndex = null;
                            _disabledOptionIndices.clear();
                          });
                          _startTimer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.background,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Пройти снова',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category.title)),
        body: const Center(child: Text('Вопросы отсутствуют')),
      );
    }

    final question = widget.category.questions[_currentIndex];
    final total = widget.category.questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Progress Header & Timer
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Вопрос ${_currentIndex + 1} из $total',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _secondsLeft <= 5
                          ? AppTheme.accentRose.withAlpha(40)
                          : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _secondsLeft <= 5
                            ? AppTheme.accentRose
                            : AppTheme.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 15,
                          color: _secondsLeft <= 5
                              ? AppTheme.accentRose
                              : AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_secondsLeft сек',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _secondsLeft <= 5
                                ? AppTheme.accentRose
                                : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.surfaceBorder,
                valueColor: AlwaysStoppedAnimation<Color>(widget.category.color),
                minHeight: 5,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 14),

              // Tactical Lifelines Row (Inside body to prevent any AppBar overflow)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _answered ? null : _use5050Lifeline,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.surfaceBorder),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.filter_2, size: 16, color: AppTheme.accentGold),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '50/50 (${_quizService.lifeline5050Count})',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _answered ? null : _useExtraTime,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.surfaceBorder),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.more_time, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '+20с (${_quizService.extraTimeCount})',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Question Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.category.color.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${question.points} Монет',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: widget.category.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Квиз РПЛ',
                            textAlign: TextAlign.end,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Options
              ...List.generate(question.options.length, (index) {
                final optionText = question.options[index];
                final isDisabled = _disabledOptionIndices.contains(index);

                Color borderColor = AppTheme.surfaceBorder;
                Color bgColor = AppTheme.surface;
                Color textColor = AppTheme.textPrimary;
                Widget? trailingIcon;

                if (_answered) {
                  if (index == question.correctIndex) {
                    borderColor = AppTheme.secondary;
                    bgColor = AppTheme.secondary.withAlpha(35);
                    trailingIcon = const Icon(Icons.check_circle, color: AppTheme.secondary, size: 20);
                  } else if (index == _selectedOptionIndex) {
                    borderColor = AppTheme.accentRose;
                    bgColor = AppTheme.accentRose.withAlpha(35);
                    trailingIcon = const Icon(Icons.cancel, color: AppTheme.accentRose, size: 20);
                  }
                } else if (isDisabled) {
                  textColor = AppTheme.textMuted;
                  bgColor = AppTheme.surface.withAlpha(80);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: (_answered || isDisabled)
                        ? null
                        : () => _onOptionSelected(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.surfaceBorder.withAlpha(100),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              optionText,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (trailingIcon != null) ...[
                            const SizedBox(width: 8),
                            trailingIcon,
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Explanation & Continue Action
              if (_answered) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (_selectedOptionIndex == question.correctIndex)
                          ? AppTheme.secondary.withAlpha(120)
                          : AppTheme.accentRose.withAlpha(120),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            (_selectedOptionIndex == question.correctIndex)
                                ? Icons.verified
                                : Icons.info_outline,
                            size: 16,
                            color: (_selectedOptionIndex == question.correctIndex)
                                ? AppTheme.secondary
                                : AppTheme.accentRose,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (_selectedOptionIndex == question.correctIndex)
                                  ? 'Верное решение!'
                                  : (_selectedOptionIndex == -1 ? 'Время истекло!' : 'Неверный ответ!'),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: (_selectedOptionIndex == question.correctIndex)
                                    ? AppTheme.secondary
                                    : AppTheme.accentRose,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        question.explanation,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex < total - 1 ? 'Следующий вопрос' : 'Результаты квиза',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

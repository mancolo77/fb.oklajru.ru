import 'package:flutter/material.dart';
import '../../services/user_progress_service.dart';
import '../../theme/app_theme.dart';

class ArticleItem {
  final String id;
  final String category;
  final String title;
  final String summary;
  final String content;
  final String readTime;

  const ArticleItem({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.content,
    required this.readTime,
  });
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final UserProgressService _progress = UserProgressService();

  int _selectedQuizAnswer = -1;
  bool _quizSubmitted = false;

  final List<ArticleItem> _articles = const [
    ArticleItem(
      id: 'fb_art_1',
      category: 'Футбол • Тактика',
      title: 'Плотность полузащиты и выход из-под давления',
      summary: 'Разбираем перемещения опорного полузащитника при розыгрыше от своих ворот.',
      content: 'Опорный полузащитник современного клуба выполняет роль метронома. При начале атаки он опускается третьим центральным защитником или создает численный треугольник для безопасной передачи.',
      readTime: '3 мин',
    ),
    ArticleItem(
      id: 'fb_art_2',
      category: 'Хоккей • Скорость',
      title: 'Входы в зону по флангам и смещения центрального',
      summary: 'Как позиционная атака в хоккее ломает оборонительные построения 1-3-1.',
      content: 'Скорость доставки шайбы через синюю линию определяет успех позиционного давления. Нападающие используют скрещивание и оставление шайбы за спину, вынуждая защитников терять концентрацию.',
      readTime: '4 мин',
    ),
    ArticleItem(
      id: 'fb_art_3',
      category: 'Баскетбол • Броски',
      title: 'Дуга и угол выпуска мяча: биомеханика снайперов',
      summary: 'Научный взгляд на технику трехочковых бросков с расстояния более 7 метров.',
      content: 'Оптимальный угол выпуска мяча составляет 48-52 градуса при обратном вращении со скоростью около 3 оборотов в секунду. Это увеличивает полезную площадь кольца при попадании.',
      readTime: '2 мин',
    ),
  ];

  final List<String> _facts = [
    'Футбольный судья пробегает за 90 минут матча от 9 до 13 километров.',
    'Шайба при щелчке профессионального защитника способна разогнаться до 175 км/ч.',
    'Щит в баскетболе изготавливается из высокопрочного закаленного стекла толщиной 12 мм.',
  ];

  void _openArticleDetails(ArticleItem article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isSaved = _progress.savedArticleIds.contains(article.id);
            return Container(
              padding: const EdgeInsets.all(AppTheme.screenPadding),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isSaved ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            _progress.toggleSaveArticle(article.id);
                            setModalState(() {});
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textHeadlines,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Время чтения: ${article.readTime}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.border),
                    const SizedBox(height: 16),
                    Text(
                      article.content,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textMain,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Понятно'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Главная',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeadlines,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_progress.points} баллов',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeadlines,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Спортивная аналитика, события и проверка знаний',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 18),

              // 1. Главный информационный баннер (#252B34 с красными акцентами)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bannerBackground,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.cardShadow,
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.bannerBackground,
                      Color(0xFF1E242E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'ВИКТОРИНА ДНЯ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '+35 баллов',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Какой номер носит на футболке вратарь по классической нумерации?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textHeadlines,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...[
                      'Номер 1',
                      'Номер 10',
                      'Номер 99',
                    ].asMap().entries.map((entry) {
                      final idx = entry.key;
                      final optionText = entry.value;
                      final isSelected = _selectedQuizAnswer == idx;
                      final isCorrect = (idx == 0);

                      Color btnColor = AppTheme.surfaceSmall;
                      if (_quizSubmitted) {
                        if (isCorrect) btnColor = const Color(0xFF1B5E20);
                        if (isSelected && !isCorrect) btnColor = const Color(0xFFB71C1C);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: _quizSubmitted
                              ? null
                              : () {
                                  setState(() {
                                    _selectedQuizAnswer = idx;
                                    _quizSubmitted = true;
                                    if (isCorrect) {
                                      _progress.recordQuizCompleted(35);
                                    }
                                  });
                                },
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: btnColor,
                              borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  optionText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textHeadlines,
                                  ),
                                ),
                                const Spacer(),
                                if (_quizSubmitted && isCorrect)
                                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20)
                                else if (_quizSubmitted && isSelected && !isCorrect)
                                  const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Статьи
              const Text(
                'Спортивные статьи',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textHeadlines,
                ),
              ),
              const SizedBox(height: 12),
              ..._articles.map((art) {
                final isSaved = _progress.savedArticleIds.contains(art.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: InkWell(
                    onTap: () => _openArticleDetails(art),
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceSmall,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                art.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: isSaved ? AppTheme.primary : AppTheme.textSecondary,
                                size: 22,
                              ),
                              onPressed: () => _progress.toggleSaveArticle(art.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          art.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeadlines,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          art.summary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // 3. Факты
              const Text(
                'Спортивный факт дня',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textHeadlines,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _facts[DateTime.now().minute % _facts.length],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}


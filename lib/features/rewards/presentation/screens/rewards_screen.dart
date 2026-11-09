import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';

const double kMemberProgress = 0.75;
const int kTotalPoints = 680000;

double _seg(
  Animation<double> a,
  double begin,
  double end, [
  Curve curve = Curves.easeOutCubic,
]) => Interval(begin, end, curve: curve).transform(a.value);

String _fmt(int n) =>
    n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

class Tier {
  const Tier(this.letter, this.stars, this.name, this.subtitle, this.colors);
  final String letter;
  final int stars;
  final String name;
  final String subtitle;
  final List<Color> colors;
}

const kTiers = [
  Tier('S', 1, 'Silver', "You're here now", [
    Color(0xFFE2E2E2),
    Color(0xFF9A9A9A),
  ]),
  Tier('G', 2, 'Gold', '500 pts Remaining\nto become Gold', [
    Color(0xFFFBEFA8),
    Color(0xFFE2C24E),
  ]),
  Tier('P', 3, 'Platinum', "You'll be here soon", [
    Color(0xFFD9F1FB),
    Color(0xFF8FD0EC),
  ]),
];

class RewardItem {
  const RewardItem({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.cta,
    required this.active,
    required this.art,
    this.attention = false,
  });
  final String title;
  final String subtitle;
  final String points;
  final String cta;
  final bool active;
  final bool attention;
  final Widget Function(double t) art;
}

final List<RewardItem> kChallenges = [
  RewardItem(
    title: 'Eat 4 Coco donuts',
    subtitle: '4/4',
    points: '100 pts',
    cta: 'EARN',
    active: true,
    attention: true,
    art: (t) => DonutProgressArt(
      quarters: 4 * t,
      icing: AppColors.pinkLight,
      icingDark: AppColors.pink,
    ),
  ),
  RewardItem(
    title: 'Eat 4 Choco donuts',
    subtitle: '1/4',
    points: '60 pts',
    cta: 'EARN',
    active: false,
    art: (t) => DonutProgressArt(
      quarters: 1 * t,
      icing: const Color(0xFFA9714B),
      icingDark: const Color(0xFF6B3F25),
    ),
  ),
  RewardItem(
    title: 'Drink 12 coffees',
    subtitle: '9/12',
    points: '150 pts',
    cta: 'EARN',
    active: false,
    art: (t) => CoffeeProgressArt(progress: (9 / 12) * t),
  ),
];

final List<RewardItem> kGifts = [
  RewardItem(
    title: 'Gift a dozen',
    subtitle: 'Send to a friend',
    points: '500 pts',
    cta: 'GIFT',
    active: true,
    art: (t) => GiftArt(t: t),
  ),
  RewardItem(
    title: 'Coffee for two',
    subtitle: 'Treat a colleague',
    points: '300 pts',
    cta: 'GIFT',
    active: true,
    art: (t) => GiftArt(t: t),
  ),
];

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  int _tab = 0;
  bool _firstList = true;

  @override
  void initState() {
    super.initState();
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _setTab(int i) {
    if (i == _tab) return;
    setState(() {
      _tab = i;
      _firstList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.only(top: top),
                child: Column(children: [_header(), _ladderAndRing()]),
              ),
              _tabsAndList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return AnimatedBuilder(
      animation: _entry,
      builder: (_, _) {
        final title = _seg(_entry, 0.0, 0.2);
        final slide = _seg(_entry, 0.0, 0.22);
        final pop = _seg(_entry, 0.2, 0.55, Curves.elasticOut);
        return Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: title.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - title)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "J' Donuts Rewards",
                        maxLines: 1,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Transform.translate(
                offset: Offset(160 * (1 - slide), 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Reward',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: pop,
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '3',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              fontSize: 12,
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
        );
      },
    );
  }

  Widget _ladderAndRing() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 0, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: TierStepper(entry: _entry, pulse: _pulse),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final d = box.maxWidth + 44;
                return SizedBox(
                  height: TierStepper.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: (TierStepper.height - d) / 2,
                        width: d,
                        height: d,
                        child: AnimatedBuilder(
                          animation: _entry,
                          builder: (_, _) {
                            final t = _seg(_entry, 0.10, 0.70);
                            // small "landed" bump on the number at the end
                            final bump =
                                math.sin(
                                  _seg(_entry, 0.68, 0.82, Curves.linear) *
                                      math.pi,
                                ) *
                                0.07;
                            return PointsRing(
                              t: t,
                              progress: kMemberProgress,
                              total: kTotalPoints,
                              bump: bump,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabsAndList() {
    return Stack(
      children: [
        Column(
          children: [
            Container(height: 30, color: Colors.white),
            Container(
              width: double.infinity,
              color: AppColors.pageGrey,
              padding: const EdgeInsets.fromLTRB(24, 54, 24, 0),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: _listTransition,
                  child: ChallengeList(
                    key: ValueKey<int>(_tab),
                    items: _tab == 0 ? kChallenges : kGifts,
                    // first load waits for the header/ring choreography
                    delay: _firstList
                        ? const Duration(milliseconds: 1300)
                        : Duration.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _entry,
            builder: (_, child) {
              final v = _seg(_entry, 0.48, 0.70);
              return Center(
                child: Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - v)),
                    child: child,
                  ),
                ),
              );
            },
            child: RewardTabs(selected: _tab, onChanged: _setTab),
          ),
        ),
      ],
    );
  }

  /// Tab 0 content lives "on the left", tab 1 "on the right", so going
  /// 0→1 slides the old list out left and the new one in from the right
  /// (and the reverse coming back).
  Widget _listTransition(Widget child, Animation<double> anim) {
    final tab = (child.key as ValueKey<int>).value;
    final dx = tab == 0 ? -0.10 : 0.10;
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(dx, 0),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}

class TierStepper extends StatelessWidget {
  const TierStepper({
    super.key,
    required this.entry,
    required this.pulse,
    this.current = 0,
  });

  static const double height = 104 * 2 + 56;

  final Animation<double> entry;
  final Animation<double> pulse;
  final int current;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entry,
      builder: (_, _) {
        return Column(
          children: [
            for (var i = 0; i < kTiers.length; i++)
              TierRow(
                tier: kTiers[i],
                // rows appear one after another
                enter: _seg(entry, 0.06 + 0.10 * i, 0.28 + 0.10 * i),
                // the line below the current tier fills to member progress
                fill: i == current
                    ? _seg(entry, 0.32, 0.66, Curves.easeInOut) *
                          kMemberProgress
                    : 0,
                isCurrent: i == current,
                isLast: i == kTiers.length - 1,
                pulse: pulse,
              ),
          ],
        );
      },
    );
  }
}

class TierRow extends StatelessWidget {
  const TierRow({
    super.key,
    required this.tier,
    required this.enter,
    required this.fill,
    required this.isCurrent,
    required this.isLast,
    required this.pulse,
  });

  final Tier tier;
  final double enter;
  final double fill;
  final bool isCurrent;
  final bool isLast;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final e = enter.clamp(0.0, 1.0);
    final pop = Curves.easeOutBack.transform(e);

    return SizedBox(
      height: isLast ? 56 : 104,
      child: Opacity(
        opacity: e,
        child: Transform.translate(
          offset: Offset(-18 * (1 - e), 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isLast)
                Positioned(
                  left: 18,
                  top: 54,
                  bottom: 6,
                  width: 4,
                  child: TierConnector(fill: fill),
                ),
              Positioned(
                left: 0,
                top: 0,
                width: 40,
                height: 48,
                child: Transform.scale(
                  scale: pop * (1.0),
                  child: Opacity(
                    opacity: 0.5,
                    child: CustomPaint(
                      size: const Size(36, 44),
                      painter: ShieldPainter(
                        colors: tier.colors,
                        letter: tier.letter,
                        stars: tier.stars,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 56,
                top: 2,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.name,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tier.subtitle,
                      style: GoogleFonts.nunito(fontSize: 12, height: 1.25),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TierConnector extends StatelessWidget {
  const TierConnector({super.key, required this.fill});
  final double fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFE6E7E9)),
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: fill.clamp(0.0, 1),
              widthFactor: 0.5,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShieldPainter extends CustomPainter {
  ShieldPainter({
    required this.colors,
    required this.letter,
    required this.stars,
  });
  final List<Color> colors;
  final String letter;
  final int stars;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..quadraticBezierTo(w * 0.75, h * 0.08, w, h * 0.1)
      ..lineTo(w, h * 0.55)
      ..quadraticBezierTo(w * 0.95, h * 0.85, w * 0.5, h)
      ..quadraticBezierTo(w * 0.05, h * 0.85, 0, h * 0.55)
      ..lineTo(0, h * 0.1)
      ..quadraticBezierTo(w * 0.25, h * 0.08, w * 0.5, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(Offset.zero & size),
    );
    // Color darken(Color c, double amount) {
    //   final hsl = HSLColor.fromColor(c);
    //   return hsl
    //       .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
    //       .toColor();
    // }

    // canvas.drawPath(
    //   path,
    //   Paint()
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 1.8
    //     ..strokeJoin = StrokeJoin.round
    //     ..shader = LinearGradient(
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //       colors: [darken(colors.first, 0.12), darken(colors.last, 0.22)],
    //     ).createShader(Offset.zero & size),
    // );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.6),
    );

    final starPainter = TextPainter(
      text: TextSpan(
        text: '★' * stars,
        style: TextStyle(
          fontSize: 9,
          color: Colors.black.withValues(alpha: 0.35),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    starPainter.paint(canvas, Offset((w - starPainter.width) / 2, h * 0.14));

    final letterPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.black.withValues(alpha: 0.4),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    letterPainter.paint(
      canvas,
      Offset((w - letterPainter.width) / 2, h * 0.36),
    );
  }

  @override
  bool shouldRepaint(covariant ShieldPainter old) =>
      old.letter != letter || old.stars != stars || old.colors != colors;
}

class PointsRing extends StatelessWidget {
  const PointsRing({
    super.key,
    required this.t,
    required this.progress,
    required this.total,
    this.bump = 0,
  });

  final double t;
  final double progress;
  final int total;
  final double bump;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final s = box.maxWidth;
        final count = (total * t).round();
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: RingPainter(progress: progress * t)),
            ),
            Transform.scale(
              scale: 1 + bump,
              child: SizedBox(
                width: s * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Total points',
                        style: GoogleFonts.nunito(
                          color: AppColors.pink,
                          fontWeight: FontWeight.w700,
                          fontSize: s * 0.05,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _fmt(count),
                        style: TextStyle(
                          color: AppColors.pink,
                          fontWeight: FontWeight.w800,
                          fontSize: s * 0.08,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Sprinkle {
  const _Sprinkle(this.a, this.off, this.dir);
  final double a; // position along the full circle, 0..1
  final double off; // radial offset, -0.5..0.5 of stroke
  final double dir; // rotation
}

class RingPainter extends CustomPainter {
  RingPainter({required this.progress});
  final double progress;

  // Fixed positions so sprinkles are revealed by the sweep, not re-rolled.
  static final List<_Sprinkle> _sprinkles = () {
    final rnd = math.Random(7);
    return List.generate(
      48,
      (i) => _Sprinkle(
        (i + rnd.nextDouble() * 0.6) / 48,
        (rnd.nextDouble() - 0.5) * 0.55,
        rnd.nextDouble() * math.pi,
      ),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.21;
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(
      center: center,
      radius: (size.width - stroke) / 2,
    );

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.track,
    );
    if (progress <= 0) return;

    const start = -math.pi / 2;
    final sweep = math.pi * 2 * progress;

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 2,
          transform: GradientRotation(-math.pi / 2),
          colors: [
            AppColors.pink,
            AppColors.pinkLight,
            AppColors.pink,
            AppColors.pinkLight,
            AppColors.pink,
          ],
        ).createShader(rect),
    );

    final sprinkle = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = stroke * 0.07
      ..strokeCap = StrokeCap.round;
    for (final sp in _sprinkles) {
      if (sp.a > progress - 0.006) continue;
      final a = start + sp.a * math.pi * 2;
      final r = rect.width / 2 + sp.off * stroke;
      final p = center + Offset(math.cos(a), math.sin(a)) * r;
      final d = Offset(math.cos(sp.dir), math.sin(sp.dir)) * stroke * 0.13;
      canvas.drawLine(p - d, p + d, sprinkle);
    }
  }

  @override
  bool shouldRepaint(covariant RingPainter old) => old.progress != progress;
}

class RewardTabs extends StatelessWidget {
  const RewardTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final int selected;
  final ValueChanged<int> onChanged;

  static const double w0 = 214, w1 = 92, h = 50;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _label('Eat more earn more', 0, w0),
        SizedBox(width: 8),
        _label('Gift', 1, w0),
      ],
    );
  }

  Widget _label(String text, int index, double width) {
    final sel = selected == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.blue : AppColors.pageGrey,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              color: sel ? Colors.white : AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ChallengeList extends StatefulWidget {
  const ChallengeList({
    super.key,
    required this.items,
    this.delay = Duration.zero,
  });
  final List<RewardItem> items;
  final Duration delay;

  @override
  State<ChallengeList> createState() => _ChallengeListState();
}

class _ChallengeListState extends State<ChallengeList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _item(i),
              ),
          ],
        );
      },
    );
  }

  Widget _item(int i) {
    final b = 0.10 * i;
    final enter = _seg(_c, b, b + 0.35);
    final artT = _seg(_c, b + 0.25, b + 0.70, Curves.easeInOutCubic);
    final item = widget.items[i];
    return Opacity(
      opacity: enter.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 28 * (1 - enter)),
        child: Transform.scale(
          scale: 0.96 + 0.04 * enter,
          child: ChallengeCard(
            item: item,
            artT: artT,
            attention: item.attention && artT >= 0.999,
          ),
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.item,
    required this.artT,
    required this.attention,
  });
  final RewardItem item;
  final double artT;
  final bool attention;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          SizedBox(width: 100, height: 100, child: item.art(artT)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.text),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    EarnButton(
                      label: item.cta,
                      active: item.active,
                      attention: attention,
                    ),
                    Text(
                      item.points,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.92,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _release() {
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) setState(() => _down = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _down = true);
      },
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scaleDown : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class EarnButton extends StatefulWidget {
  const EarnButton({
    super.key,
    required this.label,
    required this.active,
    this.attention = false,
  });
  final String label;
  final bool active;
  final bool attention;

  @override
  State<EarnButton> createState() => _EarnButtonState();
}

class _EarnButtonState extends State<EarnButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant EarnButton old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final on = widget.active && widget.attention;
    if (on && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!on && _c.isAnimating) {
      _c.animateTo(0, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return PressScale(
      onTap: () {}, // feedback only — intentionally no action
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.blue : const Color(0xFFE9EAEC),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: active ? Colors.white : const Color(0xFF9DA0A6),
          ),
        ),
      ),
    );
  }
}

class DonutProgressArt extends StatelessWidget {
  const DonutProgressArt({
    super.key,
    required this.quarters,
    required this.icing,
    required this.icingDark,
  });
  final double quarters;
  final Color icing;
  final Color icingDark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DonutProgressPainter(
        quarters: quarters,
        icing: icing,
        icingDark: icingDark,
      ),
    );
  }
}

class DonutProgressPainter extends CustomPainter {
  DonutProgressPainter({
    required this.quarters,
    required this.icing,
    required this.icingDark,
  });
  final double quarters;
  final Color icing;
  final Color icingDark;

  static const _sprinkleColors = [
    Color(0xFFFFFFFF),
    Color(0xFFFFD84D),
    Color(0xFF59C36A),
    Color(0xFF4FA8E8),
    Color(0xFFF2883B),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 * 0.9;

    // soft shadow
    canvas.drawCircle(
      c.translate(0, r * 0.08),
      r,
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );

    _donut(canvas, c, r, colored: false);

    if (quarters >= 3.999) {
      _donut(canvas, c, r, colored: true);
    } else if (quarters > 0) {
      final sweep = (quarters / 4).clamp(0.0, 1.0) * math.pi * 2;
      canvas.save();
      final wedge = Path()
        ..moveTo(c.dx, c.dy)
        ..arcTo(
          Rect.fromCircle(center: c, radius: r * 1.4),
          -math.pi / 2,
          sweep,
          false,
        )
        ..close();
      canvas.clipPath(wedge);
      _donut(canvas, c, r, colored: true);
      canvas.restore();
    }

    final tick = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = r * 0.03
      ..strokeCap = StrokeCap.round;
    for (var k = 0; k < 4; k++) {
      final a = -math.pi / 2 + k * math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * r * 0.31, c + dir * r * 0.99, tick);
    }
  }

  void _donut(Canvas canvas, Offset c, double r, {required bool colored}) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = colored ? const Color(0xFFD9A066) : const Color(0xFFCFCFD3),
    );
    canvas.drawCircle(
      c,
      r * 0.93,
      Paint()
        ..shader = RadialGradient(
          colors: colored
              ? [icing, icingDark]
              : const [Color(0xFFEDEDEF), Color(0xFFD9DADD)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    final rnd = math.Random(3);
    for (var i = 0; i < 46; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = r * (0.40 + rnd.nextDouble() * 0.48);
      final p = c + Offset(math.cos(a), math.sin(a)) * d;
      final dir = rnd.nextDouble() * math.pi;
      final v = Offset(math.cos(dir), math.sin(dir)) * r * 0.07;
      final col = _sprinkleColors[rnd.nextInt(_sprinkleColors.length)];
      canvas.drawLine(
        p - v,
        p + v,
        Paint()
          ..color = colored
              ? col
              : (i.isEven ? const Color(0xFFF7F7F8) : const Color(0xFFC9CACD))
          ..strokeWidth = r * 0.05
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(
      c,
      r * 0.29,
      Paint()
        ..color = colored ? const Color(0xFF7A4B2A) : const Color(0xFFBDBDC1),
    );
    canvas.drawCircle(c, r * 0.23, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant DonutProgressPainter old) =>
      old.quarters != quarters ||
      old.icing != icing ||
      old.icingDark != icingDark;
}

/// Coffee cup inside a 12-segment arc that fills to [progress].
class CoffeeProgressArt extends StatelessWidget {
  const CoffeeProgressArt({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: CoffeeProgressPainter(progress));
}

class CoffeeProgressPainter extends CustomPainter {
  CoffeeProgressPainter(this.progress, {this.segments = 12});
  final double progress;
  final int segments;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = size.center(Offset.zero);
    final stroke = s * 0.12;
    final rect = Rect.fromCircle(center: c, radius: (s - stroke) / 2);

    // track
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFFF3E9DE),
    );

    // fill
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(
            startAngle: 0,
            endAngle: math.pi * 2,
            transform: GradientRotation(-math.pi / 2),
            colors: [Color(0xFFE9B06A), Color(0xFF8F5226)],
          ).createShader(rect),
      );
    }

    // segment separators (12 units)
    final sep = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final rr = rect.width / 2;
    for (var i = 0; i < segments; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / segments;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + dir * (rr - stroke / 2),
        c + dir * (rr + stroke / 2),
        sep,
      );
    }

    // cup
    final cw = s * 0.30, ch = s * 0.22;
    final left = c.dx - cw / 2 - s * 0.025;
    final top = c.dy - ch / 2 + s * 0.05;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(left + cw / 2, top + ch + s * 0.012),
        width: cw * 1.45,
        height: s * 0.05,
      ),
      Paint()..color = const Color(0xFFD9B78C),
    );
    canvas.drawArc(
      Rect.fromLTWH(left + cw * 0.88, top + ch * 0.12, cw * 0.42, ch * 0.62),
      -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..color = const Color(0xFF8B5A2B),
    );
    final body = RRect.fromLTRBAndCorners(
      left,
      top,
      left + cw,
      top + ch,
      bottomLeft: Radius.circular(cw * 0.38),
      bottomRight: Radius.circular(cw * 0.38),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA56A36), Color(0xFF7C4A22)],
        ).createShader(body.outerRect),
    );
    canvas.drawOval(
      Rect.fromLTWH(left, top - ch * 0.10, cw, ch * 0.22),
      Paint()..color = const Color(0xFF4A2B17),
    );

    // steam
    final steam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFB98B5E).withValues(alpha: 0.7);
    for (final k in [0.3, 0.64]) {
      final x = left + cw * k;
      canvas.drawPath(
        Path()
          ..moveTo(x, top - ch * 0.2)
          ..cubicTo(
            x - s * 0.03,
            top - ch * 0.45,
            x + s * 0.03,
            top - ch * 0.6,
            x,
            top - ch * 0.85,
          ),
        steam,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CoffeeProgressPainter old) =>
      old.progress != progress;
}

class GiftArt extends StatelessWidget {
  const GiftArt({super.key, required this.t});
  final double t;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: GiftPainter(t));
}

class GiftPainter extends CustomPainter {
  GiftPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, s * 0.46, Paint()..color = const Color(0xFFEAF6FB));

    final k = 0.6 + 0.4 * Curves.elasticOut.transform(t.clamp(0.0, 1.0));
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(k);
    canvas.translate(-c.dx, -c.dy);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * .22, s * .46, s * .56, s * .34),
        Radius.circular(s * .04),
      ),
      Paint()..color = AppColors.blue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * .17, s * .36, s * .66, s * .13),
        Radius.circular(s * .03),
      ),
      Paint()..color = const Color(0xFF5BB6D8),
    );
    canvas.drawRect(
      Rect.fromLTWH(s * .455, s * .36, s * .09, s * .44),
      Paint()..color = AppColors.pink,
    );
    final bow = Paint()..color = AppColors.pinkLight;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * .42, s * .31),
        width: s * .18,
        height: s * .10,
      ),
      bow,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * .58, s * .31),
        width: s * .18,
        height: s * .10,
      ),
      bow,
    );
    canvas.drawCircle(
      Offset(s * .5, s * .33),
      s * .045,
      Paint()..color = const Color(0xFFC4478A),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GiftPainter old) => old.t != t;
}

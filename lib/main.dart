import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() => runApp(const CarbonApp());

class CarbonApp extends StatefulWidget {
  const CarbonApp({super.key});

  @override
  State<CarbonApp> createState() => _CarbonAppState();
}

class _CarbonAppState extends State<CarbonApp> {
  // Seed colors you asked for: light purple, pink, white-ish, sky blue
  final List<Color> _seeds = <Color>[
    const Color(0xFFD9C2FF), // light purple
    const Color(0xFFFFC2E7), // pink
    const Color(0xFFF5F7FF), // soft white/ice
    const Color(0xFFBEE3FF), // sky blue (light)
  ];

  int _seedIndex = 0;

  void _shuffleTheme() {
    setState(() => _seedIndex = (_seedIndex + 1) % _seeds.length);
  }

  @override
  Widget build(BuildContext context) {
    final seed = _seeds[_seedIndex];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carbon Goal',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.onChangeTheme});
  final VoidCallback onChangeTheme;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat(reverse: true);

  late final AnimationController _progressCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..forward();

  double target = 1.0; // 100% target bar length
  double progress = 0.70; // 70% actual progress

  // Bottom quick actions open/close
  bool _fabOpen = false;

  @override
  void dispose() {
    _bgCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primaryContainer,
        elevation: 0,
        title: const Text('Carbon Goal Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Change theme color',
            onPressed: widget.onChangeTheme,
            icon: const Icon(Icons.color_lens),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated soft gradient background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) {
              final t = _bgCtrl.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFFEEE5FF), const Color(0xFFFFE6F5), t)!,
                      Color.lerp(const Color(0xFFE8F3FF), const Color(0xFFFDFBFF), 1 - t)!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GlowCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Goal Progress',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You are ${ (progress * 100).toStringAsFixed(0)}% towards your monthly goal.',
                        style: TextStyle(color: cs.onSurface.withOpacity(.8)),
                      ),
                      const SizedBox(height: 16),
                      _RoundedProgressBar(
                        progress: CurvedAnimation(
                          parent: _progressCtrl,
                          curve: Curves.easeOutCubic,
                        ).drive(Tween<double>(begin: 0, end: progress)).value,
                        background: cs.secondaryContainer.withOpacity(.35),
                        foreground: cs.primary,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _Pill(
                            color: cs.primaryContainer,
                            icon: Icons.flag_rounded,
                            label: 'Target 100%',
                          ),
                          const SizedBox(width: 8),
                          _Pill(
                            color: cs.secondaryContainer,
                            icon: Icons.co2_rounded,
                            label: 'Actual ${(progress * 100).toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fancy quick tiles
                _SmallTiles(
                  onInsights: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InsightsPage()),
                    );
                  },
                  onAdd: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const PredictionScreen(),
    ),
  );
},

onHistory: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const HistoryScreen(),
    ),
  );
},
                  onShare: () => _toast('Share progress'),
                ),

                const SizedBox(height: 20),

                _GlowCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tips',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      _TipRow(icon: Icons.directions_walk, text: 'Prefer walking/cycling for short trips.'),
                      _TipRow(icon: Icons.flash_on, text: 'Turn off idle devices & use LED lighting.'),
                      _TipRow(icon: Icons.recycling, text: 'Recycle and reduce single-use plastics.'),
                      _TipRow(icon: Icons.cloud, text: 'Use cloud backups on Wi-Fi instead of mobile data.'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom-center expandable FAB with 4 actions
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Center(
              child: _ExpandableFab(
                open: _fabOpen,
                onToggle: () => setState(() => _fabOpen = !_fabOpen),
                items: [
                  _FabItem(Icons.insights, 'Insights', () {
                    setState(() => _fabOpen = false);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const InsightsPage()),
                    );
                  }),
                  _FabItem(Icons.add_task_rounded, 'Add Goal', () {
                    setState(() => _fabOpen = false);
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const PredictionScreen(),
  ),
);
                  }),
                  _FabItem(Icons.history_rounded, 'History', () {
                    setState(() => _fabOpen = false);
                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const HistoryScreen(),
  ),
);
              
                  }),
                  _FabItem(Icons.share_rounded, 'Share', () {
                    setState(() => _fabOpen = false);
                    _toast('Shared!');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------- Reusable UI pieces -------------------------- */

class _GlowCard extends StatelessWidget {
  const _GlowCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(.18),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(.65),
            blurRadius: 10,
            spreadRadius: -6,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(color: cs.primary.withOpacity(.08)),
      ),
      child: child,
    );
  }
}

class _RoundedProgressBar extends StatelessWidget {
  const _RoundedProgressBar({
    required this.progress,
    required this.background,
    required this.foreground,
  });

  final double progress; // 0..1
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, value, __) {
          return Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(color: background),
              ),
              FractionallySizedBox(
                widthFactor: max(0.02, value),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        foreground,
                        foreground.withOpacity(.75),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.icon, required this.label});
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onPrimaryContainer.withOpacity(.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: cs.onPrimaryContainer.withOpacity(.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallTiles extends StatelessWidget {
  const _SmallTiles({
    required this.onInsights,
    required this.onAdd,
    required this.onHistory,
    required this.onShare,
  });

  final VoidCallback onInsights;
  final VoidCallback onAdd;
  final VoidCallback onHistory;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget createButton(IconData icon, String label, VoidCallback onPressed) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: createButton(Icons.insights_rounded, 'Insights', onInsights)),
        const SizedBox(width: 10),
        Expanded(child: createButton(Icons.add_task_rounded, 'Add Goal', onAdd)),
        const SizedBox(width: 10),
        Expanded(child: createButton(Icons.history_rounded, 'History', onHistory)),
        const SizedBox(width: 10),
        Expanded(child: createButton(Icons.share_rounded, 'Share', onShare)),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: cs.onTertiaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/* ----------------------- Expandable Bottom-Center FAB ---------------------- */

class _FabItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _FabItem(this.icon, this.label, this.onTap);
}

class _ExpandableFab extends StatefulWidget {
  const _ExpandableFab({
    required this.items,
    required this.open,
    required this.onToggle,
  });

  final List<_FabItem> items;
  final bool open;
  final VoidCallback onToggle;

  @override
  State<_ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<_ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

  @override
  void didUpdateWidget(covariant _ExpandableFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Action buttons
          Positioned(
            bottom: 70,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                return Opacity(
                  opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut).value,
                  child: IgnorePointer(
                    ignoring: _ctrl.value == 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.items.length, (i) {
                        final item = widget.items[i];
                        final offset = (i + 1) * 60.0;
                        return Transform.translate(
                          offset: Offset(0, (1 - _ctrl.value) * offset),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MiniActionButton(
                              icon: item.icon,
                              label: item.label,
                              onTap: item.onTap,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main FAB
          GestureDetector(
            onTap: widget.onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary,
                    cs.primary.withOpacity(.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(.35),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.open ? Icons.close_rounded : Icons.menu_rounded,
                    key: ValueKey(widget.open),
                    color: cs.onPrimary,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.secondaryContainer,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 190,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cs.secondary.withOpacity(.18),
                blurRadius: 14,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: cs.onSecondaryContainer),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* --------------------------------- Insights -------------------------------- */

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        backgroundColor: cs.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _InsightRow(label: 'CO₂ Saved', value: '24.3 kg'),
                _InsightRow(label: 'Green Days', value: '18 / 30'),
                _InsightRow(label: 'Top Action', value: 'Walking + Public Transit'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Quick Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 10),
                Text('• Batch errands to cut short car trips.\n• Use power-saving mode on devices.\n• Plan weekly meals to reduce food waste.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: cs.onSurface.withOpacity(.75)))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("Login Success")),
);
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DashboardScreen(
      onChangeTheme: () {},
    ),
  ),
);

                },
                child: const Text("Login"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
                child: const Text("Create Account / Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          onChangeTheme: () {},
        ),
      ),
    );
  },
  child: const Text("Create Account"),
),
             
            
  
          ],
        ),
      ),
    );
  }
}
class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prediction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: "Enter travel km",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text("Login Successful"),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResultScreen(),
                  ),
                );
              },
              child: const Text("Predict"),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
      ),
      body: const Center(
        child: Text(
          "Predicted CO₂ : 18 kg",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Prediction 1"),
            subtitle: Text("15 kg CO₂"),
          ),
          ListTile(
            title: Text("Prediction 2"),
            subtitle: Text("18 kg CO₂"),
          ),
        ],
      ),
    );
  }
}

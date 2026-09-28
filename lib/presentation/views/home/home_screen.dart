import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context, auth),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildHeroBanner(context, auth),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Features', 'What can Domexa do?'),
                  const SizedBox(height: 16),
                  _buildFeaturesGrid(context),
                  const SizedBox(height: 28),
                  _buildSectionHeader('Quick Start', 'Begin your project now'),
                  const SizedBox(height: 16),
                  _buildStartProjectCard(context),
                  const SizedBox(height: 16),
                  _buildExportCard(context), // NEW: Export option
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                      'Why Domexa?', 'Built for Pakistani homeowners'),
                  const SizedBox(height: 16),
                  _buildWhyCards(),
                  const SizedBox(height: 28),
                  _buildAIBadge(),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildChatFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, AuthViewModel auth) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.architecture, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(children: [
            TextSpan(
                text: 'Dom',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary, letterSpacing: -0.5)),
            TextSpan(
                text: 'exa',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: AppColors.primary, letterSpacing: -0.5)),
          ]),
        ),
      ]),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.primary, size: 20),
          ),
          onPressed: () {},
        ),
        GestureDetector(
          onTap: () => _showProfileMenu(context, auth),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  void _showProfileMenu(BuildContext context, AuthViewModel auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            if (auth.isLoggedIn) ...[
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  auth.userName.isNotEmpty
                      ? auth.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(auth.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18,
                      color: AppColors.textPrimary)),
              Text(auth.userEmail,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              _menuItem(Icons.logout_outlined, 'Sign Out', AppColors.error,
                      () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  }),
            ] else ...[
              const Text('Guest Mode',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text('Sign in to save your projects',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              _menuItem(Icons.login_outlined, 'Sign In', AppColors.primary,
                      () => Navigator.pushReplacementNamed(context, '/login')),
              const SizedBox(height: 10),
              _menuItem(Icons.person_add_outlined, 'Create Account',
                  AppColors.cardMaterials,
                      () => Navigator.pushReplacementNamed(context, '/register')),
            ],
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: color, fontSize: 15)),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, color: color, size: 14),
        ]),
      ),
    );
  }

  // ─── Hero Banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context, AuthViewModel auth) {
    final greeting =
    auth.isLoggedIn ? 'Hello, ${auth.userName}! 👋' : 'Welcome to Domexa! 🏡';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(painter: _GridPatternPainter()),
            ),
          ),
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10))
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 100, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(greeting,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 12),
                const Text('Build Your\nDream Home',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w900,
                        color: Colors.white, height: 1.15, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('AI layouts, materials & cost\nestimation in seconds.',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.5)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/plot-input'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Start New Project',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.arrow_forward,
                              color: AppColors.primary, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, letterSpacing: -0.3)),
        const SizedBox(height: 3),
        Text(subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  // ─── Features Grid ──────────────────────────────────────────────────────────
  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      _FeatureItem('AI Layout\nGenerator', Icons.space_dashboard_outlined,
          AppColors.cardLayout, '/plot-input', 'Auto-generate floor plans'),
      _FeatureItem('Material\nGuide', Icons.inventory_2_outlined,
          AppColors.cardMaterials, '/materials', 'Best materials for budget'),
      _FeatureItem('Cost\nEstimator', Icons.calculate_outlined,
          AppColors.cardCost, '/cost', 'Accurate PKR cost breakdown'),
      _FeatureItem('Interior\nDesign', Icons.palette_outlined,
          AppColors.cardInterior, '/interior', 'Style your rooms'),
      _FeatureItem('Export\nReport', Icons.picture_as_pdf_outlined,
          AppColors.cardLayout, '/export', 'PDF & sharing'), // NEW: Export feature
    ];

    return Column(
      children: [
        // Row 1
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _featureCard(context, features[0])),
              const SizedBox(width: 14),
              Expanded(child: _featureCard(context, features[1])),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Row 2
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _featureCard(context, features[2])),
              const SizedBox(width: 14),
              Expanded(child: _featureCard(context, features[3])),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Row 3 - Export feature
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _featureCard(context, features[4])),
              const SizedBox(width: 14),
              Expanded(child: const SizedBox()), // Placeholder for balance
            ],
          ),
        ),
      ],
    );
  }

  Widget _featureCard(BuildContext context, _FeatureItem f) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, f.route),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                  color: f.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(f.icon, color: f.color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(f.title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3)),
            const SizedBox(height: 4),
            Text(f.subtitle,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4)),
            const SizedBox(height: 12),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: f.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('Open',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: f.color)),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 12, color: f.color),
            ]),
          ],
        ),
      ),
    );
  }

  // ─── Start Project Card ─────────────────────────────────────────────────────
  Widget _buildStartProjectCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/plot-input'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_home_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create New Project',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  SizedBox(height: 3),
                  Text('Enter plot details and let AI design your home.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4)),
                ],
              )),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_forward,
                color: AppColors.primary, size: 18),
          ),
        ]),
      ),
    );
  }

  // ─── NEW: Export Card ───────────────────────────────────────────────────────
  Widget _buildExportCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/export'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.picture_as_pdf_outlined,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Export Project',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  SizedBox(height: 3),
                  Text('Generate PDF report with your complete house plan.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4)),
                ],
              )),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_forward,
                color: AppColors.primary, size: 18),
          ),
        ]),
      ),
    );
  }

  // ─── Why Cards ──────────────────────────────────────────────────────────────
  Widget _buildWhyCards() {
    final items = [
      _WhyItem(Icons.psychology_outlined, 'AI-Powered',
          'Intelligent layout generation built for Pakistan.',
          AppColors.cardLayout),
      _WhyItem(Icons.currency_rupee, 'PKR Costs',
          'Real 2025 market prices for all materials.', AppColors.cardCost),
      _WhyItem(Icons.location_on_outlined, 'Pakistan-Specific',
          'Local climate, materials, and standards.',
          AppColors.cardMaterials),
      _WhyItem(Icons.bolt_outlined, 'Save Time',
          'Complete plan in minutes, not weeks.', AppColors.cardInterior),
    ];
    return Column(
        children: items.map((item) => _buildWhyCard(item)).toList());
  }

  Widget _buildWhyCard(_WhyItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(item.icon, color: item.color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(item.desc,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ],
            )),
      ]),
    );
  }

  // ─── AI Badge ───────────────────────────────────────────────────────────────
  Widget _buildAIBadge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ]),
      child: const Row(children: [
        Icon(Icons.verified_outlined, color: Colors.white, size: 32),
        SizedBox(width: 16),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COMSATS University Project',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700, fontSize: 14)),
                SizedBox(height: 3),
                Text(
                    'Final Year Project — BS Software Engineering 2023–2027\nSahiwal Campus',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 11, height: 1.5)),
              ],
            )),
      ]),
    );
  }

  // ─── FAB - Chatbot with HIGH CONTRAST for visibility ───────────────────────
  Widget _buildChatFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ]),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/chatbot'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
        label: const Text('AI Expert',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 0.5)),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────
class _FeatureItem {
  final String title, subtitle, route;
  final IconData icon;
  final Color color;
  const _FeatureItem(
      this.title, this.icon, this.color, this.route, this.subtitle);
}

class _WhyItem {
  final IconData icon;
  final String title, desc;
  final Color color;
  const _WhyItem(this.icon, this.title, this.desc, this.color);
}

// ─── Grid background painter ─────────────────────────────────────────────────
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
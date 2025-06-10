import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AnimatedHeader extends StatefulWidget {
  const AnimatedHeader({super.key});

  @override
  State<AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundDark,
            AppTheme.surfaceDark.withOpacity(0.5),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _slideController,
          _glowController,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAnimatedTitle(),
                  const SizedBox(height: 12),
                  _buildSubtitle(),
                  const SizedBox(height: 24),
                  _buildGlowingDivider(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryTeal,
            AppTheme.primaryPurple,
            AppTheme.secondaryTeal,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(
                _glowAnimation.value * 0.5,
              ),
              blurRadius: 30 * _glowAnimation.value,
              spreadRadius: 5 * _glowAnimation.value,
            ),
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(
                _glowAnimation.value * 0.3,
              ),
              blurRadius: 40 * _glowAnimation.value,
              spreadRadius: 8 * _glowAnimation.value,
            ),
          ],
        ),
        child: const Text(
          'FinanceFlow',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryTeal.withOpacity(0.2),
            AppTheme.primaryPurple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Text(
        'Real-time Financial News & Market Data',
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGlowingDivider() {
    return Container(
      height: 2,
      width: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.primaryTeal.withOpacity(_glowAnimation.value),
            AppTheme.primaryPurple.withOpacity(_glowAnimation.value),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(_glowAnimation.value * 0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class FloatingParticles extends StatefulWidget {
  const FloatingParticles({super.key});

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = [];
  final int particleCount = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double speedX;
  late double speedY;
  late double size;
  late Color color;
  late double opacity;

  Particle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    speedX = (random.nextDouble() - 0.5) * 0.02;
    speedY = (random.nextDouble() - 0.5) * 0.02;
    size = random.nextDouble() * 3 + 1;
    color = random.nextBool() ? AppTheme.primaryTeal : AppTheme.primaryPurple;
    opacity = random.nextDouble() * 0.6 + 0.2;
  }

  void update() {
    x += speedX;
    y += speedY;

    if (x < 0 || x > 1) speedX *= -1;
    if (y < 0 || y > 1) speedY *= -1;

    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

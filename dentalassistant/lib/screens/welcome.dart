import 'package:dentalassistant/models/product.dart';
import 'package:dentalassistant/screens/admin/admin.dart';
import 'package:dentalassistant/screens/product_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late Future<List<Product>> _futureProduct;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeFuture();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  void _initializeFuture() {
    _futureProduct = Api().getProducts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildShimmerEffect(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.3),
                theme.primaryColor.withValues(alpha: 0.8),
                theme.primaryColor.withValues(alpha: 0.3),
              ],
              stops: [0.0, value, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicCard(Widget child, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? 
        (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cardColor.withValues(alpha: isDark ? 0.9 : 0.8),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Dental Assistant',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.admin_panel_settings_rounded,
                color: theme.iconTheme.color,
              ),
              tooltip: 'Admin Panel',
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AdminPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      );
                    },
                  ),
                ).then((_) {
                  if (mounted) {
                    setState(() {
                      _initializeFuture();
                    });
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            setState(() {
              _initializeFuture();
            });
            try {
              await _futureProduct;
            } catch (e) {
              // Handle error silently
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    kToolbarHeight,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 600),
                                child: _buildGlassmorphicCard(
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Logo Section with Hero Animation
                                        Hero(
                                          tag: 'dental_app_logo',
                                          child: TweenAnimationBuilder<double>(
                                            duration: const Duration(milliseconds: 2000),
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            builder: (context, value, child) {
                                              return Transform.rotate(
                                                angle: value * 2 * 3.14159,
                                                child: Container(
                                                  width: 120,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: theme.primaryColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(60),
                                                    border: Border.all(
                                                      color: theme.primaryColor.withValues(alpha: 0.3),
                                                      width: 2,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: theme.primaryColor.withValues(alpha: 0.2),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      'assets/images/logo.jpg',
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(
                                                          Icons.medical_services_rounded,
                                                          size: 64,
                                                          color: theme.primaryColor,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 32),
                                        
                                        // Welcome Text
                                        Text(
                                          'Welcome to',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            color: theme.textTheme.bodyMedium?.color,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 8),
                                        
                                        Text(
                                          'Dental Assistant',
                                          style: theme.textTheme.displayLarge?.copyWith(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textTheme.displayLarge?.color,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 16),
                                        
                                        Text(
                                          'Your comprehensive dental management solution',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: theme.textTheme.bodyMedium?.color,
                                            height: 1.5,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 48),
                                        
                                        // Future Builder Content
                                        FutureBuilder<List<Product>>(
                                          future: _futureProduct,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Column(
                                                children: [
                                                  SizedBox(
                                                    width: 32,
                                                    height: 32,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        theme.primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Loading products...',
                                                    style: theme.textTheme.bodyMedium,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildShimmerEffect(theme),
                                                ],
                                              );
                                            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                              return Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: theme.primaryColor.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.check_circle_rounded,
                                                          color: theme.primaryColor,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '${snapshot.data!.length} products loaded',
                                                          style: theme.textTheme.bodySmall?.copyWith(
                                                            color: theme.primaryColor,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        HapticFeedback.mediumImpact();
                                                        Navigator.pushAndRemoveUntil(
                                                          context,
                                                          PageRouteBuilder(
                                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                                ProductSelectionScreen(
                                                                  products: snapshot.data!,
                                                                ),
                                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                              return FadeTransition(
                                                                opacity: animation,
                                                                child: SlideTransition(
                                                                  position: animation.drive(
                                                                    Tween(begin: const Offset(0.0, 0.3), end: Offset.zero)
                                                                        .chain(CurveTween(curve: Curves.easeOut)),
                                                                  ),
                                                                  child: child,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          (route) => false,
                                                        );
                                                      },
                                                      icon: const Icon(Icons.arrow_forward_rounded),
                                                      label: const Text('Continue'),
                                                      style: ElevatedButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 32,
                                                          vertical: 16,
                                                        ),
                                                        textStyle: theme.textTheme.titleMedium?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        elevation: 4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons.error_outline_rounded,
                                                          color: theme.colorScheme.error,
                                                          size: 32,
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          'No products available',
                                                          style: theme.textTheme.titleMedium?.copyWith(
                                                            color: theme.colorScheme.error,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'Please check your connection or contact admin',
                                                          textAlign: TextAlign.center,
                                                          style: theme.textTheme.bodySmall?.copyWith(
                                                            color: theme.textTheme.bodyMedium?.color,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      HapticFeedback.lightImpact();
                                                      setState(() {
                                                        _initializeFuture();
                                                      });
                                                    },
                                                    icon: const Icon(Icons.refresh_rounded),
                                                    label: const Text('Retry'),
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  theme,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:dentalassistant/helpers/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _urlController = TextEditingController();
  bool _isUrlValid = true;
  String? _urlError;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _urlController.text = Api().baseUrl;
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _staggerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection({
    required Widget child,
    required int index,
    required int totalItems,
  }) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, _) {
        final start = (index / totalItems) * 0.3;
        final end = start + 0.7;
        
        final animationValue = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ));

        return Transform.translate(
          offset: Offset(50 * (1 - animationValue.value), 0),
          child: Opacity(
            opacity: animationValue.value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicCard(Widget child, ThemeData theme, {bool hasError = false}) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? 
        (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: cardColor.withValues(alpha: isDark ? 0.9 : 0.95),
        border: Border.all(
          color: hasError 
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.primaryColor.withValues(alpha: 0.1),
          width: hasError ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError 
                ? theme.colorScheme.error.withValues(alpha: 0.1)
                : theme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.03),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.1),
              theme.primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: theme.primaryColor,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Configure app behavior and preferences',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
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

  Widget _buildSectionCard({
    required String title,
    required String description,
    required IconData icon,
    required Widget content,
    required int index,
    ThemeData? theme,
  }) {
    theme ??= Theme.of(context);
    
    return _buildAnimatedSection(
      index: index,
      totalItems: 6,
      child: _buildGlassmorphicCard(
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              content,
            ],
          ),
        ),
        theme,
      ),
    );
  }

  Widget _buildToggleRow({
    required Future<bool> future,
    required String label,
    required IconData icon,
    required void Function(bool) onToggle,
    ThemeData? theme,
  }) {
    theme ??= Theme.of(context);
    
    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Icon(icon, color: theme!.iconTheme.color?.withValues(alpha: 0.5)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            ],
          );
        }

        final isEnabled = snapshot.data ?? false;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isEnabled 
                ? theme!.primaryColor.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled 
                  ? (theme?.primaryColor ?? Colors.blue).withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isEnabled 
                      ? theme?.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isEnabled 
                      ? theme?.primaryColor 
                      : theme?.iconTheme.color?.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme?.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.1,
                child: Switch.adaptive(
                  value: isEnabled,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    onToggle(value);
                    setState(() {}); // Trigger rebuild to show immediate feedback
                  },
                  activeColor: theme?.primaryColor,
                  activeTrackColor: theme?.primaryColor.withValues(alpha: 0.3),
                  inactiveThumbColor: theme?.colorScheme.outline,
                  inactiveTrackColor: theme?.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _validateUrl(String url) {
    if (url.isEmpty) {
      setState(() {
        _isUrlValid = false;
        _urlError = 'URL cannot be empty';
      });
      return false;
    }
    
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!url.startsWith('http://') && !url.startsWith('https://'))) {
        setState(() {
          _isUrlValid = false;
          _urlError = 'URL must start with http:// or https://';
        });
        return false;
      }
      
      setState(() {
        _isUrlValid = true;
        _urlError = null;
      });
      return true;
    } catch (e) {
      setState(() {
        _isUrlValid = false;
        _urlError = 'Invalid URL format';
      });
      return false;
    }
  }

  Widget _buildUrlInputCard(ThemeData theme) {
    return _buildAnimatedSection(
      index: 0,
      totalItems: 6,
      child: _buildGlassmorphicCard(
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cloud_rounded,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Configuration',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure the server endpoint for data synchronization',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isUrlValid)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green[600],
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://192.168.1.5/dental/api.php',
                  errorText: _urlError,
                  prefixIcon: Icon(
                    Icons.link_rounded,
                    color: _isUrlValid ? theme.primaryColor : theme.colorScheme.error,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isUrlValid)
                        Icon(
                          Icons.error_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _urlController.text = 'http://192.168.1.5/dental/api.php';
                          _validateUrl(_urlController.text);
                          Api().baseUrl = _urlController.text;
                          _showSuccessSnackBar('URL reset to default');
                        },
                        tooltip: 'Reset to default',
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isUrlValid 
                          ? theme.primaryColor.withValues(alpha: 0.3)
                          : theme.colorScheme.error,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isUrlValid 
                          ? theme.primaryColor.withValues(alpha: 0.2)
                          : theme.colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isUrlValid ? theme.primaryColor : theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor?.withValues(alpha: 0.5),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    value = 'http://192.168.1.5/dental/api.php';
                    _urlController.text = value;
                    _urlController.selection = TextSelection.fromPosition(
                      TextPosition(offset: value.length),
                    );
                  }
                  
                  if (_validateUrl(value)) {
                    Api().baseUrl = value;
                  }
                },
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
              ),
              if (_isUrlValid && _urlController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Valid API endpoint configured',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        theme,
        hasError: !_isUrlValid,
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return _buildAnimatedSection(
      index: 5,
      totalItems: 6,
      child: _buildGlassmorphicCard(
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Speech Recognition Setup',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Language Models',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.android_rounded,
                      title: 'Android',
                      description: 'Settings → Language & Input → Google Voice Typing → Offline Speech Recognition',
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.phone_iphone_rounded,
                      title: 'iOS',
                      description: 'Supported natively for certain tasks on modern devices',
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        theme,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green[600],
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[50],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                _buildAnimatedSection(
                  index: 0,
                  totalItems: 6,
                  child: _buildHeaderCard(theme),
                ),
                
                const SizedBox(height: 16),
                
                // API Configuration
                _buildUrlInputCard(theme),
                
                // Notifications
                _buildSectionCard(
                  title: 'Notifications',
                  description: 'Control notification preferences for timers and events',
                  icon: Icons.notifications_rounded,
                  index: 1,
                  content: _buildToggleRow(
                    future: SharedPreferencesHelper().showNotification(),
                    label: 'Enable Notifications',
                    icon: Icons.notifications_active_rounded,
                    onToggle: (value) {
                      SharedPreferencesHelper().saveShowNotification(value);
                    },
                    theme: theme,
                  ),
                  theme: theme,
                ),
                
                // Sound Settings
                _buildSectionCard(
                  title: 'Sound',
                  description: 'Enable sound effects for timer events and interactions',
                  icon: Icons.volume_up_rounded,
                  index: 2,
                  content: _buildToggleRow(
                    future: SharedPreferencesHelper().playSound(),
                    label: 'Enable Sound Effects',
                    icon: Icons.music_note_rounded,
                    onToggle: (value) {
                      SharedPreferencesHelper().savePlaySound(value);
                    },
                    theme: theme,
                  ),
                  theme: theme,
                ),
                
                // Vibration Settings
                _buildSectionCard(
                  title: 'Haptic Feedback',
                  description: 'Enable vibrations for timer events and touch interactions',
                  icon: Icons.vibration_rounded,
                  index: 3,
                  content: _buildToggleRow(
                    future: SharedPreferencesHelper().vibrate(),
                    label: 'Enable Vibration',
                    icon: Icons.phone_android_rounded,
                    onToggle: (value) {
                      SharedPreferencesHelper().saveVibrate(value);
                    },
                    theme: theme,
                  ),
                  theme: theme,
                ),
                
                // Speech Recognition Info
                _buildInfoCard(theme),
                
                // Bottom spacing
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
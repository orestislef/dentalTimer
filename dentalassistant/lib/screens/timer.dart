import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../helpers/notifications.dart';
import '../helpers/shared_preferences.dart';
import '../helpers/speech_recognition.dart';
import '../models/product.dart';

class TimerScreen extends StatefulWidget {
  final List<Product> products;

  const TimerScreen({
    super.key,
    required this.products,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> 
    with TickerProviderStateMixin {
  late final List<Product> productsQueue;
  late Product currentProduct;
  late int currentProductIndex;
  late int currentDurationIndex;

  late Duration remainingTime;
  late final CountDownController _controller;

  bool isTimerRunning = false;
  bool isFinishingAnimation = false;

  late final NotificationHelper notificationHelper;
  late final AudioPlayer audioPlayer;
  late final SpeechRecognitionHelper speechRecognitionHelper;

  final SharedPreferencesHelper _preferencesHelper = SharedPreferencesHelper();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _completionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _completionAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeTimer();
    _initializeServices();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
  }

  void _initializeTimer() {
    productsQueue = List.from(widget.products);
    currentProductIndex = 0;
    currentProduct = productsQueue[currentProductIndex];
    currentDurationIndex = 0;
    remainingTime = Duration(seconds: currentProduct.duration[currentDurationIndex]);
    _controller = CountDownController();
  }

  void _initializeServices() {
    notificationHelper = NotificationHelper();
    audioPlayer = AudioPlayer();

    speechRecognitionHelper = SpeechRecognitionHelper(
      onStart: (message) => _handleSpeechCommand(startCommand: true),
      onStop: (message) => _handleSpeechCommand(startCommand: false),
      onError: (error) => debugPrint('Speech Recognition Error: $error'),
    );

    speechRecognitionHelper.initialize().then((_) {
      speechRecognitionHelper.startListening();
    });

    _preferencesHelper.ensureInitialized();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _completionController.dispose();
    speechRecognitionHelper.stopListening();
    audioPlayer.dispose();
    super.dispose();
  }

  void _handleSpeechCommand({required bool startCommand}) {
    if (startCommand && !isTimerRunning) {
      startTimer();
    } else if (!startCommand && isTimerRunning) {
      stopTimer();
    }
    _triggerFeedback(isNotification: startCommand);
  }

  void _onComplete() async {
    _triggerFeedback();
    HapticFeedback.heavyImpact();

    setState(() {
      isFinishingAnimation = true;
    });

    _completionController.forward();
    
    // Create background color animation
    final theme = Theme.of(context);
    _backgroundColorAnimation = ColorTween(
      begin: theme.scaffoldBackgroundColor,
      end: theme.colorScheme.primary.withValues(alpha: 0.1),
    ).animate(_completionController);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isFinishingAnimation = false;
      isTimerRunning = false;
    });

    _completionController.reset();

    if (currentDurationIndex < currentProduct.duration.length - 1) {
      setState(() {
        currentDurationIndex++;
        remainingTime = Duration(seconds: currentProduct.duration[currentDurationIndex]);
      });
    } else if (currentProductIndex < productsQueue.length - 1) {
      _sendNotification("${currentProduct.title} timers finished!");
      setState(() {
        currentProductIndex++;
        currentProduct = productsQueue[currentProductIndex];
        currentDurationIndex = 0;
        remainingTime = Duration(seconds: currentProduct.duration[currentDurationIndex]);
      });
    } else {
      _sendNotification("All products and timers are finished!");
      _showCompletionDialog();
    }
  }

  Future<void> _sendNotification(String message) async {
    if (await _preferencesHelper.showNotification()) {
      notificationHelper.sendNotification(
        title: "Timer Notification",
        message: message,
      );
    }
  }

  Future<void> _triggerFeedback({bool isNotification = true}) async {
    if (await _preferencesHelper.playSound()) {
      _playSound(isNotification: isNotification);
    }
    if (await _preferencesHelper.vibrate()) {
      _vibrate();
    }
  }

  Future<void> _playSound({bool isNotification = true}) async {
    try {
      await audioPlayer.play(
        AssetSource(
          isNotification ? "sound/notification.mp3" : "sound/dink.mp3",
        ),
      );
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  Future<void> _vibrate() async {
    try {
      final enabled = await SharedPreferencesHelper().vibrate();
      if (!enabled) return;

      if (await Vibration.hasVibrator() ?? false) {
        if (await Vibration.hasAmplitudeControl() ?? false) {
          Vibration.vibrate(
            pattern: [300, 200, 300, 200],
            intensities: [128, 0, 255, 0],
          );
        } else {
          Vibration.vibrate(duration: 1000);
        }
      } else {
        debugPrint("Vibration not supported on this device");
      }
    } catch (e) {
      debugPrint("Error during vibration: $e");
    }
  }

  void startTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      isTimerRunning = true;
    });
    _controller.start();
    _pulseController.repeat(reverse: true);
  }

  void stopTimer() {
    HapticFeedback.lightImpact();
    setState(() {
      isTimerRunning = false;
    });
    _controller.pause();
    _pulseController.stop();
    _pulseController.reset();
  }

  Widget _buildGlassmorphicCard(Widget child, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? 
        (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: cardColor.withValues(alpha: isDark ? 0.9 : 0.95),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.08),
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

  Widget _buildProgressIndicator(ThemeData theme) {
    final totalSteps = productsQueue.fold<int>(
      0, (sum, product) => sum + product.duration.length,
    );
    
    int currentStep = 0;
    for (int i = 0; i < currentProductIndex; i++) {
      currentStep += productsQueue[i].duration.length;
    }
    currentStep += currentDurationIndex + 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '$currentStep / $totalSteps',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.celebration_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "All Timers Finished",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Congratulations! You have completed all timers for all products.",
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Back to Products"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _completionController,
      builder: (context, child) {
        final backgroundColor = isFinishingAnimation && _backgroundColorAnimation != null
            ? _backgroundColorAnimation!.value
            : theme.scaffoldBackgroundColor;
            
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    "${currentProduct.title}",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: speechRecognitionHelper.isListening,
                  builder: (context, isListening, child) {
                    return Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (isListening ? theme.colorScheme.error : theme.iconTheme.color)
                            ?.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.mic_rounded,
                        color: isListening ? theme.colorScheme.error : theme.iconTheme.color,
                        size: 18,
                      ),
                    );
                  },
                ),
              ],
            ),
            centerTitle: false,
            elevation: 0,
            backgroundColor: backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: theme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${currentDurationIndex + 1}/${currentProduct.duration.length}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              child: Column(
                children: [
                  // Progress Indicator
                  _buildProgressIndicator(theme),
                  
                  // Main Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildGlassmorphicCard(
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Product Description
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.primaryColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  currentProduct.description,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.headlineSmall?.color,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Timer Circle
                              ScaleTransition(
                                scale: isTimerRunning ? _pulseAnimation : 
                                       isFinishingAnimation ? _completionAnimation :
                                       const AlwaysStoppedAnimation(1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(alpha: 0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: CircularCountDownTimer(
                                    duration: remainingTime.inSeconds,
                                    controller: _controller,
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    height: MediaQuery.of(context).size.width * 0.7,
                                    fillColor: theme.primaryColor,
                                    backgroundColor: Colors.transparent,
                                    strokeWidth: 8.0,
                                    strokeCap: StrokeCap.round,
                                    textStyle: TextStyle(
                                      fontSize: 42.0,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    isTimerTextShown: true,
                                    autoStart: false,
                                    isReverse: true,
                                    isReverseAnimation: true,
                                    onComplete: _onComplete,
                                    ringColor: theme.primaryColor.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Control Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (isTimerRunning) {
                                      stopTimer();
                                    } else {
                                      startTimer();
                                    }
                                    _triggerFeedback();
                                  },
                                  icon: Icon(
                                    isTimerRunning 
                                        ? Icons.pause_rounded 
                                        : Icons.play_arrow_rounded,
                                    size: 28,
                                  ),
                                  label: Text(
                                    isTimerRunning ? 'Pause Timer' : 'Start Timer',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 20,
                                    ),
                                    backgroundColor: isTimerRunning 
                                        ? theme.colorScheme.error 
                                        : theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 6,
                                    shadowColor: (isTimerRunning 
                                        ? theme.colorScheme.error 
                                        : theme.primaryColor).withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        theme,
                      ),
                    ),
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
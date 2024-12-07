import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../helpers/notifications.dart';
import '../helpers/shared_preferences.dart';
import '../helpers/speech_recognition.dart';
import '../models/product.dart';

class TimerScreen extends StatefulWidget {
  final List<Product> products;

  const TimerScreen({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
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

  @override
  void initState() {
    super.initState();

    // Initialize variables
    productsQueue = List.from(widget.products);
    currentProductIndex = 0;
    currentProduct = productsQueue[currentProductIndex];
    currentDurationIndex = 0;

    remainingTime =
        Duration(seconds: currentProduct.duration[currentDurationIndex]);
    _controller = CountDownController();
    notificationHelper = NotificationHelper();
    audioPlayer = AudioPlayer();

    // Initialize Speech Recognition
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

    setState(() {
      isFinishingAnimation = true;
    });

    // Wait for animation to finish
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isFinishingAnimation = false;
      isTimerRunning = false; // Ensure the next timer doesn't auto-start
    });

    if (currentDurationIndex < currentProduct.duration.length - 1) {
      // Move to the next duration for the current product
      setState(() {
        currentDurationIndex++;
        remainingTime =
            Duration(seconds: currentProduct.duration[currentDurationIndex]);
      });
    } else if (currentProductIndex < productsQueue.length - 1) {
      // Move to the next product
      _sendNotification("${currentProduct.title} timers finished!");
      setState(() {
        currentProductIndex++;
        currentProduct = productsQueue[currentProductIndex];
        currentDurationIndex = 0;
        remainingTime =
            Duration(seconds: currentProduct.duration[currentDurationIndex]);
      });
    } else {
      // All products and their durations are completed
      _sendNotification("All products and timers are finished!");
      _showCompletionDialog();
    }
  }

  Future<void> _sendNotification(String message) async {
    notificationHelper.sendNotification(
      title: "Timer Notification",
      message: message,
    );
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
            isNotification ? "sound/notification.mp3" : "sound/dink.mp3"),
      );
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  Future<void> _vibrate() async {
    try {
      // Check if vibration is enabled in user preferences
      final enabled = await SharedPreferencesHelper().vibrate();
      if (!enabled) return;

      // Check if the device supports vibration
      if (await Vibration.hasVibrator() ?? false) {
        // Use pattern if amplitude control is supported, else use a simple vibration
        if (await Vibration.hasAmplitudeControl() ?? false) {
          Vibration.vibrate(
            pattern: [300, 200, 300, 200], // Vibration on/off pattern
            intensities: [128, 0, 255, 0], // Optional intensities (if supported)
          );
        } else {
          // Fallback to simple vibration
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
    setState(() {
      isTimerRunning = true;
    });
    _controller.start();
  }

  void stopTimer() {
    setState(() {
      isTimerRunning = false;
    });
    _controller.pause();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("All Timers Finished"),
        content: const Text("You have completed all timers for all products."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isFinishingAnimation ? Colors.red : Colors.white,
        title: Row(
          children: [
            Text(
              "${currentProduct.title} (${currentProductIndex + 1}/${productsQueue.length})",
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<bool>(
              valueListenable: speechRecognitionHelper.isListening,
              builder: (context, isListening, child) {
                return Icon(
                  Icons.mic,
                  color: isListening ? Colors.red : Colors.grey,
                );
              },
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(
                    Icons.timer,
                    color: Colors.blue,
                  ),
                  Text(
                    "${currentDurationIndex + 1}/${currentProduct.duration.length}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isFinishingAnimation ? Colors.red : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentProduct.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CircularCountDownTimer(
              duration: remainingTime.inSeconds,
              controller: _controller,
              width: MediaQuery.of(context).size.width / 1.5,
              height: MediaQuery.of(context).size.height / 2.0,
              fillColor: Colors.blue,
              backgroundColor: null,
              strokeWidth: 10.0,
              strokeCap: StrokeCap.round,
              textStyle: const TextStyle(
                fontSize: 48.0,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              isTimerTextShown: true,
              autoStart: false,
              isReverse: true,
              isReverseAnimation: true,
              onComplete: _onComplete,
              ringColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isTimerRunning ? stopTimer : startTimer,
              child: Text(isTimerRunning ? 'Stop Timer' : 'Start Timer'),
            ),
          ],
        ),
      ),
    );
  }
}

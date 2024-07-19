import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:dentalassistant/helpers/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import '../helpers/speech_recognition.dart';
import '../models/product.dart';

class TimerScreen extends StatefulWidget {
  final Product product1;
  final Product product2;

  const TimerScreen(
      {super.key, required this.product1, required this.product2});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AudioPlayer audioPlayer;
  late CountDownController _controller;

  late Product currentProduct;
  late Duration remainingTime;
  bool isTimerRunning = false;
  bool bothTimersFinished = false;
  bool isFinishingAnimation = false;

  late SpeechRecognitionHelper _speechHelper;
  late bool _hasSpeechToText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentProduct = widget.product1;
    remainingTime = currentProduct.duration;

    _controller = CountDownController();

    _initializeNotificationPlugin();
    _requestNotificationPermission();

    // Initialize audio player
    audioPlayer = AudioPlayer();

    _hasSpeechToText = true;
    _speechHelper = SpeechRecognitionHelper(
      onStart: (message) {
        debugPrint(message);
        _playSound();
      },
      onStop: (message) {
        debugPrint(message);
        _playSound();
      },
      onError: (String text) {
        debugPrint(text);
        _hasSpeechToText = false;
      },
    );
    _speechHelper.initialize().then((value) {
      _speechHelper.startListening();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speechHelper.stopListening();
    super.dispose();
  }

  void _initializeNotificationPlugin() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);
    localNotificationsPlugin.initialize(initSettings);
  }

  void _requestNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      // Notifications are allowed
    } else {
      // Notifications are not allowed
    }
  }

  void _sendNotification(String message) async {
    bool enabled = await SharedPreferencesHelper().showNotification();
    if (!enabled) {
      return;
    }
    const androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const generalNotificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotificationsPlugin.show(
      0,
      'Timer Notification',
      message,
      generalNotificationDetails,
    );
  }

  void _playSound() {
    SharedPreferencesHelper().playSound().then((enabled) {
      if (enabled) {
        audioPlayer.play(AssetSource('sound/notification.mp3'));
      }
    });
  }

  void _vibrate() {
    SharedPreferencesHelper().vibrate().then((enabled) {
      if (enabled) {
        Vibration.vibrate(duration: 2000, pattern: [300, 200, 300, 200]);
      }
    });
  }

  void startTimer() {
    setState(() {
      isTimerRunning = true;
    });
    _controller.start();
  }

  void _onComplete() {
    setState(() {
      isFinishingAnimation = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isFinishingAnimation = false; // Reset the animation
      });
    });
    if (currentProduct == widget.product1) {
      setState(() {
        currentProduct = widget.product2;
        remainingTime = currentProduct.duration;
        isTimerRunning = false;
        _sendNotification('First product timer finished!');
        _controller.restart(duration: remainingTime.inSeconds);
        _controller.pause();
      });
    } else {
      setState(() {
        isTimerRunning = false;
        bothTimersFinished = true;
        _sendNotification('Second product timer finished!');
      });
    }
    _playSound();
    _vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer for ${currentProduct.title}'),
      ),
      backgroundColor: isFinishingAnimation ? Colors.red : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: bothTimersFinished
                ? [
                    const Text(
                      'Timers finished!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ]
                : [
                    Text(
                      currentProduct.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                      onPressed: isTimerRunning ? null : startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Start Timer'),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

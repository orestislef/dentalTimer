import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef SpeechCallback = void Function(String text);

class SpeechRecognitionHelper {
  late stt.SpeechToText _speech;
  final ValueNotifier<bool> isListening = ValueNotifier<bool>(false); // Use a single ValueNotifier
  SpeechCallback onStart;
  SpeechCallback onStop;
  SpeechCallback onError;

  SpeechRecognitionHelper({
    required this.onStart,
    required this.onStop,
    required this.onError,
  }) {
    _speech = stt.SpeechToText();
  }

  Future<void> initialize() async {
    await _ensurePermissions();
    try {
      await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
    } catch (e) {
      onError("Speech recognition not available on this device");
    }
  }

  Future<void> _ensurePermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      isListening.value = false; // Update the existing ValueNotifier
    } else if (status == 'listening') {
      isListening.value = true;
    }
  }

  void _onError(SpeechRecognitionError error) {
    isListening.value = false; // Update the existing ValueNotifier
    onError("Error: ${error.errorMsg}");
  }

  void startListening() {
    if (!isListening.value) {
      _speech.listen(
        onResult: _onResult,
      );
      isListening.value = true; // Update the existing ValueNotifier
    }
  }

  void stopListening() {
    if (isListening.value) {
      _speech.stop();
      isListening.value = false; // Update the existing ValueNotifier
    }
  }

  void _onResult(SpeechRecognitionResult result) async {
    if (result.recognizedWords.isNotEmpty) {
      String recognizedWords = result.recognizedWords.toLowerCase();

      if (recognizedWords.contains("start")) {
        onStart("Start command recognized");
        _restartListening(); // Stop and restart listening
      } else if (recognizedWords.contains("stop")) {
        onStop("Stop command recognized");
        _restartListening(); // Stop and restart listening
      }
    }
  }

  void _restartListening() async {
    stopListening(); // Stop the current session
    await Future.delayed(const Duration(milliseconds: 500));
    startListening(); // Start a new session
  }
}

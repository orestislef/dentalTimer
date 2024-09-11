import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef SpeechCallback = void Function(String text);

class SpeechRecognitionHelper {
  late stt.SpeechToText _speech;
  bool _isListening = false;
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
      _isListening = false;
    }
  }

  void _onError(SpeechRecognitionError error) {
    _isListening = false;
    onError("Error: ${error.errorMsg}");
  }

  void startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: _onResult,
      );
      _isListening = true;
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    if (result.recognizedWords.isNotEmpty) {
      String recognizedWords = result.recognizedWords.toLowerCase();
      if (recognizedWords.contains("start")) {
        onStart("Start command recognized");
      } else if (recognizedWords.contains("stop")) {
        onStop("Stop command recognized");
      }
    }
  }
}

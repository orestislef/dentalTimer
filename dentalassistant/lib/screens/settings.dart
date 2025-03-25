import 'package:dentalassistant/helpers/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../api/api.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: "Notification Settings",
              description:
                  "Control whether you want to receive notifications about timers and other events.",
            ),
            _buildToggleSwitch(
              future: SharedPreferencesHelper().showNotification(),
              labelOn: 'Notifications On',
              labelOff: 'Notifications Off',
              iconOn: Icons.notifications_active_rounded,
              iconOff: Icons.notifications_off,
              onToggle: (index) {
                SharedPreferencesHelper().saveShowNotification(index == 0);
              },
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(
              title: "Sound Settings",
              description:
                  "Enable or disable sound effects during timer events or speech commands.",
            ),
            _buildToggleSwitch(
              future: SharedPreferencesHelper().playSound(),
              labelOn: 'Sound On',
              labelOff: 'Silent Mode',
              iconOn: Icons.volume_up_rounded,
              iconOff: Icons.volume_off,
              onToggle: (index) {
                SharedPreferencesHelper().savePlaySound(index == 0);
              },
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(
              title: "Vibration Settings",
              description:
                  "Choose whether to enable vibrations during timer events or speech commands.",
            ),
            _buildToggleSwitch(
              future: SharedPreferencesHelper().vibrate(),
              labelOn: 'Vibration On',
              labelOff: 'No Vibration',
              iconOn: Icons.vibration_rounded,
              iconOff: Icons.cancel_rounded,
              onToggle: (index) {
                SharedPreferencesHelper().saveVibrate(index == 0);
              },
            ),
            const SizedBox(height: 30),
            _buildInfoTile(
              title: "Offline Speech Recognition",
              description:
                  "Ensure that offline language models are downloaded:\n\n"
                  "• Android: Settings → Language & Input → Google Voice Typing → Offline Speech Recognition.\n"
                  "• iOS: Supported natively for certain tasks on modern devices.",
              icon: Icons.info_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        //text url input
        TextField(
          controller: TextEditingController(text: Api().baseUrl),
          onChanged: (string) {
            if (string.isEmpty) {
              string = 'http://192.168.1.5/dental/api.php';
            }
            Api().baseUrl = string;
          },
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildToggleSwitch({
    required Future<bool> future,
    required String labelOn,
    required String labelOff,
    required IconData iconOn,
    required IconData iconOff,
    required void Function(int) onToggle,
  }) {
    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          return ToggleSwitch(
            minWidth: double.infinity,
            initialLabelIndex: snapshot.data! ? 0 : 1,
            activeBgColor: const [Colors.blue],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey.shade300,
            inactiveFgColor: Colors.black,
            totalSwitches: 2,
            labels: [labelOn, labelOff],
            icons: [iconOn, iconOff],
            onToggle: (index) => onToggle(index!), // Explicit function call
          );
        }
      },
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}

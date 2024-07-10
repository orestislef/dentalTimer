import 'package:dentalassistant/helpers/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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
      body: Center(
        child: Column(
          children: [
            FutureBuilder<bool>(
                future: SharedPreferencesHelper().showNotification(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  } else {
                    return ToggleSwitch(
                      minWidth: 200.0,
                      initialLabelIndex: snapshot.data! ? 0 : 1,
                      activeBgColor: const [Colors.blue],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      labels: const ['Notifications', 'No notifications'],
                      icons: const [
                        Icons.notifications_active_rounded,
                        Icons.notifications_off
                      ],
                      activeBgColors: const [
                        [Colors.blue],
                        [Colors.blue]
                      ],
                      onToggle: (index) {
                        SharedPreferencesHelper()
                            .saveShowNotification(index == 0);
                      },
                    );
                  }
                }),
            const SizedBox(height: 20),
            FutureBuilder<bool>(
                future: SharedPreferencesHelper().playSound(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  } else {
                    return ToggleSwitch(
                      minWidth: 200.0,
                      initialLabelIndex: snapshot.data! ? 0 : 1,
                      activeBgColor: const [Colors.blue],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      labels: const ['Sound', 'Silent mode'],
                      icons: const [Icons.volume_up_rounded, Icons.volume_off],
                      activeBgColors: const [
                        [Colors.blue],
                        [Colors.blue]
                      ],
                      onToggle: (index) {
                        SharedPreferencesHelper().savePlaySound(index == 0);
                      },
                    );
                  }
                }),
            const SizedBox(height: 20),
            FutureBuilder<bool>(
                future: SharedPreferencesHelper().vibrate(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  } else {
                    return ToggleSwitch(
                      minWidth: 200.0,
                      initialLabelIndex: snapshot.data! ? 0 : 1,
                      activeBgColor: const [Colors.blue],
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      labels: const ['Vibrate', 'No vibration'],
                      icons: const [
                        Icons.vibration_rounded,
                        Icons.cancel_rounded
                      ],
                      activeBgColors: const [
                        [Colors.blue],
                        [Colors.blue]
                      ],
                      onToggle: (index) {
                        SharedPreferencesHelper().saveVibrate(index == 0);
                      },
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}

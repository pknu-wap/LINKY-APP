import 'package:flutter/material.dart';

class AlarmSetupWidget extends StatefulWidget {
  final Future<void> Function(DateTime scheduledTime) onSetAlarm;
  final String buttonText;

  const AlarmSetupWidget({
    super.key,
    required this.onSetAlarm,
    this.buttonText = 'Set Alarm (Vibrate Only)',
  });

  @override
  State<AlarmSetupWidget> createState() => _AlarmSetupWidgetState();
}

class _AlarmSetupWidgetState extends State<AlarmSetupWidget> {
  int _selectedHour = DateTime.now().hour;
  int _selectedMinute = (DateTime.now().minute + 1) % 60;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 시간 선택
              DropdownButton<int>(
                value: _selectedHour,
                items: List.generate(24, (index) => DropdownMenuItem(
                  value: index,
                  child: Text(index.toString().padLeft(2, '0')),
                )),
                onChanged: (value) => setState(() => _selectedHour = value!),
              ),
              const Text(' : ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              // 분 선택
              DropdownButton<int>(
                value: _selectedMinute,
                items: List.generate(60, (index) => DropdownMenuItem(
                  value: index,
                  child: Text(index.toString().padLeft(2, '0')),
                )),
                onChanged: (value) => setState(() => _selectedMinute = value!),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final now = DateTime.now();
              var scheduledTime = DateTime(
                now.year, now.month, now.day, _selectedHour, _selectedMinute,
              );

              // 이미 지난 시간이면 내일로 설정
              if (scheduledTime.isBefore(now)) {
                scheduledTime = scheduledTime.add(const Duration(days: 1));
              }

              await widget.onSetAlarm(scheduledTime);
            },
            child: Text(widget.buttonText),
          ),
        ],
      ),
    );
  }
}
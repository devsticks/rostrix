import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  final ValueNotifier<double> progressNotifier;
  final List<String> messages;

  const LoadingOverlay({
    Key? key,
    required this.progressNotifier,
    required this.messages,
  }) : super(key: key);

  @override
  _LoadingOverlayState createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  int _messageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _messageIndex = Random().nextInt(widget.messages.length);
    _startMessageRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMessageRotation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _messageIndex++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black87,
            child: Center(
              child: ValueListenableBuilder<double>(
                valueListenable: widget.progressNotifier,
                builder: (context, progress, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                          value: progress, color: Colors.white),
                      const SizedBox(height: 20),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.messages[_messageIndex % widget.messages.length],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

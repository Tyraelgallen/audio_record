import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyWidget2(),
    );
  }
}

class MyWidget2 extends StatefulWidget {
  const MyWidget2({super.key});

  @override
  State<MyWidget2> createState() => _MyWidget2State();
}

class _MyWidget2State extends State<MyWidget2> {
  final recorder = FlutterSoundRecorder();

  bool isRecorderReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRecorder();
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: "audio");
  }

  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audiofile = File(path!);
    print(audiofile);
  }

  Future initRecorder() async {
    var status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      return;
    }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
              builder: (context, snapshot) {
                final duration =
                    snapshot.hasData ? snapshot.data!.duration : Duration.zero;

                String twoDigits(int n) => n.toString().padLeft(2, "0");
                final myMinutes = twoDigits(duration.inMinutes.remainder(60));
                final mySeconds = twoDigits(duration.inSeconds.remainder(60));

                // return Text("${duration.inSeconds}");
                return Text(
                  "$myMinutes:$mySeconds",
                  style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                );
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (recorder.isRecording) {
                  await stop();
                } else {
                  await record();
                }
                setState(() {});
              },
              child: Icon(recorder.isRecording ? Icons.stop : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}

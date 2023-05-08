
import 'package:flutter/material.dart';
import 'package:vlc_recorder/recorder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VLC Recorder',
      theme: ThemeData.dark(),
      // home: const PopupMenuExample(),
      home: const StreamDownloader(streamUrl: 'https://live.sgpc.net:8443/;nocache=889869',),
    );
  }
}


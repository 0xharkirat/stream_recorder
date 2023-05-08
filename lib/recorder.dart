import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StreamDownloader extends StatefulWidget {
  final String streamUrl;

  const StreamDownloader({super.key, required this.streamUrl});

  @override
  _StreamDownloaderState createState() => _StreamDownloaderState();
}

class _StreamDownloaderState extends State<StreamDownloader> {
  late http.StreamedResponse _response;
  late bool _downloading;

  var client;
  bool loading = false;

  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();

    _downloading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Downloader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? const CircularProgressIndicator()
                : Text(
                    'Recorded: ${_formatDuration(_elapsedTime)}',
                    style: const TextStyle(fontSize: 24.0),
                  ),
            if (!_downloading)
              ElevatedButton(
                onPressed: () {
                  _startDownload();
                },
                child: const Text('Start Recording'),
              ),
            if (_downloading)
              ElevatedButton(
                onPressed: () {
                  _stopDownload();
                },
                child: const Text('Stop/Save Recording'),
              ),
          ],
        ),
      ),
    );
  }

  void _startDownload() async {
    setState(() {
      _downloading = true;
      _elapsedTime = Duration.zero;
      loading = true;
    });

    client = http.Client();
    final request = http.Request('GET', Uri.parse(widget.streamUrl));
    _response = await client.send(request);

    setState(() {
      loading = false;
    });

    // final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final file = File('/storage/emulated/0/Music/live_darbar_$timestamp.mp3');

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_downloading) {
        timer.cancel();
      } else {
        setState(() {
          _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
        });
      }
    });

    await file.create();
    await _response.stream.forEach((data) {
      file.writeAsBytesSync(data, mode: FileMode.append);
    });

    setState(() {
      _downloading = false;
    });

    // cancel the stream
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);

    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _stopDownload() async {
    await client.close();
    setState(() {
      _downloading = false;
    });
  }
}

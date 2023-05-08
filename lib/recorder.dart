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
  Color _color = Colors.red;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(100);

  var client;
  bool loading = false;

  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();

    _downloading = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Downloader'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            if (!_downloading)
              ListTile(
                title: const Text('Start Recording'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  _startDownload();
                  Navigator.pop(context);
                },
              ),
            if (_downloading)
              ListTile(
                title: const Text('Stop/Save Recording'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  _stopDownload();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            opacity: _downloading ? 1 : 0,
            duration: const Duration(seconds: 1),
            child: AnimatedContainer(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: _borderRadius,
                ),
                // Define how long the animation should take.
                duration: const Duration(seconds: 1),
                // Provide an optional curve to make the animation feel smoother.
                curve: Curves.fastOutSlowIn,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                          onTap: _stopDownload,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.stop_circle_rounded,
                                color: Colors.red,
                              ),
                              Text(
                                _formatDuration(_elapsedTime),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    )),
          ),
        ),
      ),
    );
  }

  void _startDownload() async {
    setState(() {
      _color = Colors.red;
      _borderRadius = BorderRadius.circular(100);
      _downloading = true;
      _elapsedTime = Duration.zero;
      loading = true;
    });

    client = http.Client();
    final request = http.Request('GET', Uri.parse(widget.streamUrl));
    _response = await client.send(request);

    setState(() {
      loading = false;
      _color = Colors.white;
      _borderRadius = BorderRadius.circular(50);
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
      _elapsedTime = Duration.zero;
      _downloading = false;
    });
  }
}

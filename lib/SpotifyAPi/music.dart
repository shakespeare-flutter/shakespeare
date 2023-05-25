import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:async/async.dart';

import '../SelectedBooks.dart';

enum PlayState {
  none,
  pausing,
  playing
}

const String address = 'http://10.0.2.2:5000/music?id='; // for emulator
//const String address = 'http://192.168.25.4:5000/music?id='; // for device

class MusicPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final MusicSelector _musicSelector = MusicSelector();

  static const Duration fadeOutTime = Duration(milliseconds: 2000);
  static const Duration fadeInTime = Duration(milliseconds: 2000);
  static const Duration interval = Duration(milliseconds: 500);
  static const Duration tick = Duration(milliseconds: 50);

  PlayState _state = PlayState.none;
  PlayState get state => _state;

  void _updateState(PlayState state) {
    _state = state;
    debugPrint(state.toString());
    _controller.add(_state);
  }

  static final MusicPlayer _instance = MusicPlayer._privateConstructor();
  factory MusicPlayer() => _instance;
  MusicPlayer._privateConstructor() {
    _audioPlayer.setLoopMode(LoopMode.all);
    _musicSelector.stream.listen((String path) {
      if (state == PlayState.playing) {
        play();
      }
    });
  }

  _Token? _future;
  double _volume = 0;

  final StreamController<PlayState> _controller = StreamController<PlayState>.broadcast();
  Stream<PlayState> get stream => _controller.stream;

  void _fadeInAndOut(String? music) async {
    Future<void> inner(_Token op) async{
      int t;
      if (state != PlayState.none) {
        if (music == null) {
          _updateState(PlayState.pausing);
        }
        else {
          _updateState(PlayState.playing);
        }

        t = (fadeOutTime.inMilliseconds * _volume).toInt();
        while (t >= 0) {
          await Future.delayed(tick);
          if (op.isCanceled) {
            return;
          }
          t -= tick.inMilliseconds;
          _volume = t.toDouble() / fadeOutTime.inMilliseconds;
          _audioPlayer.setVolume(_volume);
        }
        _audioPlayer.setVolume(_volume = 0);
        _audioPlayer.pause();
        if (music == null) {
          _updateState(PlayState.none);
          return;
        }
        await Future.delayed(interval);
        if (op.isCanceled) {
          return;
        }
      } else {
        if (music == null) {
          _updateState(PlayState.none);
          return;
        }
        else {
          _updateState(PlayState.playing);
        }
      }

      try {
        await _audioPlayer.setUrl(music);
        if (op.isCanceled) {
          return;
        }
        _audioPlayer.play();
      }
      catch (e) {
        _updateState(PlayState.none);
        return;
      }
      if (op.isCanceled) {
        return;
      }

      // fade in
      t = 0;
      while (t < fadeInTime.inMilliseconds) {
        await Future.delayed(tick);
        if (op.isCanceled) {
          return;
        }
        t += tick.inMilliseconds;
        _volume = t.toDouble() / fadeInTime.inMilliseconds;
        _audioPlayer.setVolume(_volume);
      }
      _audioPlayer.setVolume(_volume = 1);
    }
    await _future?.cancel();
    _future = _Token();
    _future!.act(inner(_future!));
  }
  void play() => _fadeInAndOut(_musicSelector.music);
  void pause() => _fadeInAndOut(null);
  void dispose() => _audioPlayer.dispose();
}

class _Token {
  bool _isCanceled = false;
  bool get isCanceled => _isCanceled;
  CancelableOperation? _op;

  void act(Future<dynamic> op) {
    _isCanceled = false;
    _op = CancelableOperation.fromFuture(op);
  }
  Future<void> cancel() async {
    _isCanceled = true;
    await _op?.cancel();
  }
}

class MusicControlButton extends StatelessWidget {
  final MusicPlayer player = MusicPlayer();
  MusicControlButton({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayState>(
        stream: player.stream,
        builder: (context, snapshot) {
          switch (snapshot.data ?? player.state) {
            case PlayState.none:
            case PlayState.pausing:
              return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  color: Colors.white,
                  iconSize: 40.0,
                  onPressed: () {
                    player.play();
                  }
              );
            case PlayState.playing:
              return IconButton(
                icon: const Icon(Icons.pause),
                color: Colors.white,
                iconSize: 40.0,
                onPressed: player.pause,
              );
          }
        });
  }
}

// 임시 음악 선정
class MusicSelector {
  List<String> list = [ '1', '2', '3' ];

  static final MusicSelector _instance = MusicSelector._privateConstructor();
  factory MusicSelector() => _instance;

  String _music = 'Title';
  String get music => _music;

  int _index = -1;
  MusicSelector._privateConstructor() {
    update();
  }

  void update() async {
    _index++;
    if (_index >= list.length) {
      _index = 0;
    }
    _music = list[_index];
    _controller.add(_music);
  }

  final StreamController<String> _controller = StreamController<String>.broadcast();
  Stream<String> get stream => _controller.stream;
}

// 임시 음악 변경 버튼
class NextMusicButton extends StatelessWidget {
  final MusicSelector selector = MusicSelector();
  NextMusicButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      color: Colors.white,
      iconSize: 40.0,
      onPressed: selector.update,
    );
  }
}

class MusicMetaData extends StatelessWidget {
  MusicMetaData({super.key, required this.musicPV2});
  final MusicSelector selector = MusicSelector();
  final MusicProvider musicPV2;  //넘겨받은 인자


  @override
  Widget build(BuildContext context) {
    String musicName=musicPV2.ENG; //사용
    String musicMood=musicPV2.MOOD; //사용

    return StreamBuilder<String>(
        stream: selector.stream,
        builder: (context, snapshot) {
          String data = musicPV2.music; //바꿔본 부분
          return Column(
            children: [
              Image.asset(
                'assets/title.png',
                height: 256,
                width: 256,
              ),
              Text(basenameWithoutExtension(data), style: const TextStyle(color: Colors.white, fontSize: 40)),
              Text(musicMood, style: TextStyle(color: Colors.white, fontSize: 24)),
            ]
          );
        });
  }
}
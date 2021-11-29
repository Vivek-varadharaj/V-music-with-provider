// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:v_music_player/provider/music_provider.dart';

import 'package:v_music_player/style/style.dart';

class AddToPlaylistTile extends StatelessWidget {
  final Box<List<dynamic>>? allSongsBox = Hive.box("allSongsBox");

  final Audio? audioModel;

  final String playlistName;
  AddToPlaylistTile(this.audioModel, this.playlistName);
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        {
          if (_timer != null) {
            _timer!.cancel();
          }
          _timer = Timer(Duration(milliseconds: 300), () {
            Provider.of<MusicProvider>(context, listen: false)
                .addToPlaylist(audioModel, context, playlistName);
          });
        }
        ;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Container(
          height: 60,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      playlistName,
                      style: StyleForApp.heading,
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Container(
                    child: (playlistName != "Favorites")
                        ? Icon(
                            FontAwesomeIcons.arrowAltCircleRight,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.red,
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

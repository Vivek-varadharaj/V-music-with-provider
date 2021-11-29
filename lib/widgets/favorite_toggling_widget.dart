

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/data_base/audio_model.dart';
import 'package:v_music_player/data_base/database_functions.dart';
import 'package:v_music_player/provider/music_provider.dart';

// ignore: must_be_immutable
class FavoriteToggling extends StatefulWidget {
  Audio? audioModel;
  List<Audio> audioSongs;

  FavoriteToggling(this.audioSongs);

  @override
  _FavoriteTogglingState createState() => _FavoriteTogglingState();
}

class _FavoriteTogglingState extends State<FavoriteToggling> {
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.withId("0");
  AudioModel? favorite;
  bool isFavorite = false;
  List<Audio> audioSongs = [];
  List<Audio> myAudioModelSongs = [];
  DatabaseFunctions db = DatabaseFunctions.getDatabase();
  void decideColor() {
    favorite = AudioModel(
        album: widget.audioModel!.metas.album,
        id: widget.audioModel!.metas.extra!["id"],
        path: widget.audioModel!.path,
        title: widget.audioModel!.metas.title);

        List<AudioModel> audioModelSongs = db.audioToMyAudioModel(myAudioModelSongs);

    isFavorite = db.isExists(audioModelSongs, favorite);

    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return assetsAudioPlayer.builderCurrent(builder: (context, playing) {
      
      return Consumer<MusicProvider>(builder: (context, provider, child) {
        print("favorite also rebuild");
        myAudioModelSongs = provider.getSongs("Favorites");
        widget.audioModel = find(widget.audioSongs, playing.audio.assetAudioPath);
      decideColor();
        return GestureDetector(
          onTap: () {
            if (isFavorite) {
              myAudioModelSongs.removeWhere((element) =>
                  element.metas.extra!["id"] ==
                  widget.audioModel!.metas.extra!["id"]);
              List<AudioModel> audioSongs =
                  db.audioToMyAudioModel(myAudioModelSongs);
              Provider.of<MusicProvider>(context,listen: false)
                  .insertSongs(audioSongs, "Favorites");
            } else
              Provider.of<MusicProvider>(context,listen: false).addToPlaylistIndividually(
                  widget.audioModel, "Favorites", context);
            
          },
          child: Icon(
            FontAwesomeIcons.heart,
            color: isFavorite ? Colors.red : Colors.white,
            size: width < 600 ? 22 : 32,
          ),
        );
      });
    });
  }

  Audio find(List<Audio> audioModelSongs, String path) {
    return audioModelSongs.firstWhere((element) => element.path == path);
  }
}

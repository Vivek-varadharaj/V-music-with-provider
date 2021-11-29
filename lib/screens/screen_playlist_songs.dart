import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/data_base/audio_model.dart';
import 'package:v_music_player/data_base/database_functions.dart';
import 'package:v_music_player/provider/music_provider.dart';
import 'package:v_music_player/style/style.dart';
import 'package:v_music_player/widgets/add_songs_individully_to_playlist.dart';
import 'package:v_music_player/widgets/app_bar.dart';

import 'package:v_music_player/widgets/playlist_song_tile_display.dart';

class PlaylistSongsScreen extends StatefulWidget {
  final String playlistName;
  PlaylistSongsScreen(this.playlistName);

  @override
  State<PlaylistSongsScreen> createState() => _PlaylistSongsScreenState();
}

class _PlaylistSongsScreenState extends State<PlaylistSongsScreen> {
  // final Box<List<dynamic>>? allSongsBox = Hive.box("allSongsBox");
  DatabaseFunctions db = DatabaseFunctions.getDatabase();
  List<AudioModel>? audioModelSongs;
  List<Audio>? audioSongs = [];
 

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
   
    return Scaffold(
      // backgroundColor: ColorsForApp.dark,
      appBar: CustomAppBar.customAppBar(widget.playlistName, context),
      body: Container(
         decoration: BoxDecoration(
              gradient: StyleForApp.bodyTheme,
            ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child:  Consumer<MusicProvider>(
                builder: (context,provider,child) {
                  print("this also rebuild");
                  audioSongs =provider.getSongs(widget.playlistName);
                    audioSongs = audioSongs!.reversed.toList();                       
                     return ListView(children: [
                          widget.playlistName != "Favorites" &&
                                  widget.playlistName != "Recent Songs" &&
                                  widget.playlistName != "All Songs"
                              ? AddIndividulSongsToPlaylist(
                                 widget.playlistName)
                              : Container(),
                          ...audioSongs!
                              .map(
                                (audioSong) => PlaylistSongTile(
                                  audioSong,
                                  audioSongs!,
                                  audioSongs!.indexOf(audioSong),
                                  widget.playlistName,
                                  
                                ),
                              )
                              .toList()
                        ]);
                      }
                      
                      
                   
                  ),
             
              )
             
    );
  }
}

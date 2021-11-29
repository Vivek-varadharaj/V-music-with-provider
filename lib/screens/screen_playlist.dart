
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/provider/music_provider.dart';

import 'package:v_music_player/style/style.dart';
import 'package:v_music_player/widgets/app_bar.dart';
import 'package:v_music_player/widgets/create_play_list.dart';

import 'package:v_music_player/widgets/playlist_tile.dart';

class PlayListScreen extends StatefulWidget {
 final String playlistName;

  PlayListScreen(this.playlistName);

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  final Box<List<dynamic>>? allSongsBox = Hive.box("allSongsBox");

  List<String>? playlistNames = [];

  


 

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // backgroundColor: ColorsForApp.dark,
      appBar: CustomAppBar.customAppBar(widget.playlistName,context),
      body: Container(
         decoration: BoxDecoration(
              gradient: StyleForApp.bodyTheme,
            ),
        padding: const EdgeInsets.all(10.0),
        child: Consumer<MusicProvider>(
          builder: (context, provider, child) {
            List<String> playlists = provider.getPlaylistNames();
            return Builder(
              builder: (context) {
                return ListView(
                  children:  [
                    Container(
                      child: (widget.playlistName == "Playlists")
                          ? CreatePlaylist()
                          : Container(),
                    ),
                   ...playlists.map((PlaylistName) =>  PlaylistTile(PlaylistName,)).toList()
                  ],
                );
              }
            );
          }
        ),
      ),
    );
  }
}

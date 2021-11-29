

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/data_base/audio_model.dart';
import 'package:v_music_player/data_base/database_functions.dart';
import 'package:v_music_player/provider/music_provider.dart';
import 'package:v_music_player/style/style.dart';
import 'package:v_music_player/widgets/app_bar.dart';
import 'package:v_music_player/widgets/menu_tile.dart';
import 'package:v_music_player/widgets/recent_song_tile.dart';

class Library extends StatefulWidget {
  

 

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  DatabaseFunctions db = DatabaseFunctions.getDatabase();
  List<String> titles = [
    "Playlists",
    "Albums",
    "Favorites"
  ];

  List<Audio> audioSongs = [];




  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar.customAppBar("Library",context),
      body: Container(
        decoration: BoxDecoration(
              gradient: StyleForApp.bodyTheme,
            ),
        padding: const EdgeInsets.only(top: 10.0, left: 20,right: 20,bottom: 60),
        child: Consumer<MusicProvider>(
          builder: (context,provider, child) {
            audioSongs = provider.getSongs("Recent Songs");
            audioSongs = audioSongs.reversed.toList();
            return GridView.count(
              crossAxisCount: 1,
              childAspectRatio: 5,
              mainAxisSpacing: 4,
              children: [
                ...titles.map((playlistName) => MenuTile(playlistName)),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 40),
                  child: Text("Recent Songs", style: width< 600 ? StyleForApp.tileDisc : StyleForApp.tileDiscLarge),
                ),

               ... audioSongs.map(
                  (e) => RecentSongTile(
                   audioModel: e,
                  audioModelSongs: audioSongs,
                   index: audioSongs.indexOf(e),
                   playlistName: "Recent Songs",
                 
                  ),
                ),
                
                // ...
              ],
            );
          }
        ),
      ),
    );
  }
}

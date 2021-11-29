import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/provider/music_provider.dart';
import 'package:v_music_player/style/style.dart';

import 'package:v_music_player/widgets/add_to_playlist_tile.dart';
import 'package:v_music_player/widgets/app_bar.dart';
import 'package:v_music_player/widgets/create_play_list.dart';

class AddToPlaylistScreen extends StatefulWidget {
 final Audio? audioModel;
  AddToPlaylistScreen(this.audioModel);

  @override
  State<AddToPlaylistScreen> createState() => _AddToPlaylistScreenState();
}

class _AddToPlaylistScreenState extends State<AddToPlaylistScreen> {
  final Box<List<dynamic>> allSongsBox = Hive.box("allSongsBox");

  List<String>? playlistNames=[];
 



 

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // backgroundColor: ColorsForApp.dark,
      appBar: CustomAppBar.customAppBar("Add to playlist",context),
      body: Consumer<MusicProvider>(
        builder: (context, provider, child) {
          playlistNames = provider.getPlaylistNames();
          playlistNames =
        playlistNames!.where((element) => element != "Favorites" && element !="All Songs" && element != "Recent Songs").toList();
          return Container(
            decoration: BoxDecoration(
              gradient: StyleForApp.bodyTheme,
            ),
            padding: const EdgeInsets.all(8.0),
            child:  playlistNames!.length>0 ?  ListView(
              children: [
                      CreatePlaylist(),
                  ...playlistNames!.map((playlistNames) => AddToPlaylistTile(widget.audioModel, playlistNames)).toList()] )
              
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
    children: [
            Center(child: Text("No Playlists yet!!",style: StyleForApp.heading,)),
    ],
              )
              ,
            );
        }
      ),
   
    );
  }
}

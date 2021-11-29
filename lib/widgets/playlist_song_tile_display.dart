



import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/audio_player/player.dart';
import 'package:v_music_player/data_base/audio_model.dart';
import 'package:v_music_player/data_base/database_functions.dart';
import 'package:v_music_player/provider/music_provider.dart';
import 'package:v_music_player/screens/screen_now_playing.dart';
import 'package:v_music_player/style/style.dart';

class PlaylistSongTile extends StatefulWidget {

  final Audio audioModel;
  final List<Audio> audioModelSongs;
  final index;
 final String? playlistName;
 

  PlaylistSongTile(this.audioModel, this.audioModelSongs, this.index,
      this.playlistName, );

  @override
  _PlaylistSongTileState createState() => _PlaylistSongTileState();
}

class _PlaylistSongTileState extends State<PlaylistSongTile> {
  Player player = Player.getAudioPlayer();
  DatabaseFunctions db = DatabaseFunctions.getDatabase();
  Audio? audioModel;
  // AssetsAudioPlayer? assetsAudioPlayer = AssetsAudioPlayer.withId("0");
  @override
  void initState() {
  
    super.initState();

    getSongs();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () async {
       
          player.openPlaylistInPlayer(
            index: widget.index, audioModelSongs: widget.audioModelSongs);
        Navigator.push(
            context,
            PageTransition(
                duration: Duration(milliseconds: 200),
                type: PageTransitionType.fade,
                child: NowPlaying(widget.audioModelSongs, widget.index)));
        
        
      
      },
      child: Container(
        
        margin: EdgeInsets.only(top: 10),
        
        height:  width < 600 ? 65 : 95,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  clipBehavior: Clip.hardEdge,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  width: 60,
                  child: Center(child: audioModel!.metas.extra!["image"])),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                  child: Text(
                    widget.audioModel.metas.title!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: width < 600 ?StyleForApp.tileDisc :StyleForApp.tileDiscLarge ,
                  ),
                ),
              ),
              GestureDetector(
                  onTap: widget.playlistName !="All Songs" ?  () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              backgroundColor: ColorsForApp.goldenLow,
                              title: Column(
                                children: [
                                ListTile(
                                    onTap: () {

                                      Provider.of<MusicProvider>(context, listen:  false).
                                      deleteSongFromPlaylist(widget.audioModelSongs,widget.audioModel,widget.playlistName!); 
                                       // deletes from playlist . written below this class
                                      Navigator.of(context).pop();
                                    },
                                    title: Text(
                                      "Delete from playlist",
                                      style: StyleForApp.tileDisc,
                                    ),
                                    trailing: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  widget.playlistName != "Favorites"// checks this condition so that add to favorites option will not be available in favorites page
                                      ? ListTile(
                                          onTap: () {
                                            Provider.of<MusicProvider>(context, listen: false).addToPlaylist(audioModel, context, "Favorites");
                                           
                                          },
                                          title: Text(
                                            "Add to Favorites",
                                            style: StyleForApp.tileDisc,
                                          ),
                                          trailing: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            ));
                    
                  } : (){
                    db.addToPlaylistOrFavorites(context: context, audioModel: audioModel );
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: 40,
                    height: 60,
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.ellipsisV,
                        color: Colors.white,
                        size: width < 600 ? 18 : 28,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

// functions

  void getSongs() {
    //function for getting the song from widget top class to beneath
    audioModel = widget.audioModel;

  }

  void deleteFromPlaylist() {
    List<AudioModel> myAudioModelSongs =
        db.audioToMyAudioModel(widget.audioModelSongs);
    myAudioModelSongs
        .removeWhere((element) => element.id == audioModel!.metas.extra!['id']);
    db.insertSongs(myAudioModelSongs, widget.playlistName!);
  
    
  }
}

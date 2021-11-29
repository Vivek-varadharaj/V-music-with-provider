import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/data_base/audio_model.dart';
import 'package:v_music_player/data_base/database_functions.dart';
import 'package:v_music_player/provider/music_provider.dart';
import 'package:v_music_player/screens/screen_playlist_songs.dart';
import 'package:v_music_player/style/style.dart';

// ignore: must_be_immutable
class PlaylistTile extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  DatabaseFunctions db = DatabaseFunctions.getDatabase();
  
 

  PlaylistTile(this.title, );
   
  final String title;
  @override
  Widget build(BuildContext context) {
    double width  = MediaQuery.of(context).size.width;
    controller.text=title;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
              duration: Duration(milliseconds: 200),
                type: PageTransitionType.leftToRight,
                child: PlaylistSongsScreen(
                    title))); //Actually we will be passing the entire song list model here
      },
     
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Container(
          height:  width < 600 ? 60 : 80,
          padding: EdgeInsets.all(10),
         
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      title,
                      style: width < 600 ? StyleForApp.heading : StyleForApp.headingLarge
                      ,
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Container(
                    child: (title == "Favorites" ||
                                title == "All Songs" ||
                                title == "Favorites") ||
                            title == "Recent Songs"
                        ? Icon(
                            FontAwesomeIcons.arrowAltCircleRight,
                            color: Colors.white,
                            size:  width< 600 ?22 :32,
                          )
                        : Container()),
              ),
              title != "All Songs" &&
                      title != "Favorites" &&
                      title != "Recent Songs"
                  ? Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(context: context, builder: (context)=>
                            Container(
                               decoration: BoxDecoration(
                                 color: Colors.black,
              gradient: LinearGradient( 
                tileMode: TileMode.repeated,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black87, Colors.black54, Colors.black87, Colors.black ]
              ),
            ),
                              child: AlertDialog(
                                backgroundColor: Colors.black,
                                actionsAlignment: MainAxisAlignment.center,
                                title: TextFormField(
                                  cursorColor: Colors.white,
                  style: StyleForApp.tileDisc,
                  decoration: InputDecoration(
                    
                    focusedBorder:OutlineInputBorder(
                          borderSide: BorderSide(
                    color: Colors.white,
                  ),) ,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                    color: Colors.white,
                  ),),
                  enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        )
                  ),
                                  controller: controller,
                                  onChanged: (value){
                                   
                                  },
                                  
                                ),
                                actions: [
                                  ElevatedButton(onPressed: () async{
                                    List<AudioModel> audioModelSongs = db.getSongs(title);
                                    String keyword = controller.text;
                                  bool isItUnique = await db.isUnique(keyword);
                                    if(controller.text!="" && isItUnique){

                                      Provider.of<MusicProvider>(context,listen: false).deletePlaylist(title);
                                    
                                       Provider.of<MusicProvider>(context, listen: false).insertSongs(audioModelSongs, controller.text);
                                    
                                    
                                    Navigator.of(context).pop();
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Playlist name empty or it already exists")));
                                    }
                                   
                                  }, child: Text("Confirm"),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.black
                                  ),
                                  )
                                ],
                              ),
                            )
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Container(
                                child: Icon(
                              FontAwesomeIcons.edit,
                              color: Colors.white,
                              size: 20,
                            )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  actionsAlignment: MainAxisAlignment.spaceAround,
                                      backgroundColor: ColorsForApp.goldenLow,
                                      title: Text("Delete?"),
                                      actions: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: ColorsForApp.dark,
                                            ),
                                            onPressed: () {
                                              Provider.of<MusicProvider>(context, listen: false).deletePlaylist(title);
                                            
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Yes")),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: ColorsForApp.dark,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("No"))
                                      ],
                                    ));
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Container(
                                child: Icon(
                              FontAwesomeIcons.trash,
                              color: Colors.white,
                              size: 20,
                            )),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  //   Future<bool> isUnique(String keyword) async {
  //   int flag = 0;
  //   List<String> alreadyPlaylists =
  //       await allSongsBox!.keys.cast<String>().toList();
  //   for (String playlist in alreadyPlaylists) {
  //     if (playlist == keyword) {
  //       flag = 1;
  //     }
  //   }
  //   if (flag == 1) {
  //     return false;
  //   } else
  //     return true;
  // }
}

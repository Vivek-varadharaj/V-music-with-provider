import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:v_music_player/data_base/audio_model.dart';
import 'package:v_music_player/provider/music_provider.dart';
import 'package:v_music_player/style/style.dart';
import 'package:provider/provider.dart';

class CreatePlaylist extends StatefulWidget {
  MusicProvider provider = MusicProvider();
  
  CreatePlaylist();
  static AudioModel sample =
      AudioModel(album: "vivek", path: "null", title: "vivek", id: 2);

  @override
  State<CreatePlaylist> createState() => _CreatePlaylistState();
}

class _CreatePlaylistState extends State<CreatePlaylist> {
  final Box<List<dynamic>>? allSongsBox = Hive.box("allSongsBox");

  // List<AudioModel>? a;

  List<AudioModel> newPlaylist = [];

  // void init(){
  // //  a =newPlaylist;
  // }

  TextEditingController _controller = TextEditingController();
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.transparent,
            title: Container(
               decoration: BoxDecoration(
              gradient: LinearGradient( 
                tileMode: TileMode.repeated,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black87, Colors.black54, Colors.black87, Colors.black ]
              )
            ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 18,right: 18,top:8),
                    child: TextFormField(
                      style: StyleForApp.tileDisc,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        )
                      ),
                      controller: _controller,
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                      onPressed: () {
                      if  (_timer!=null ) {
                            _timer!.cancel();
                        }
                        _timer = Timer(Duration(milliseconds: 300), (){
                           Provider.of<MusicProvider>(context,listen: false).createPlaylist(context, _controller.text);
                        });
                        
                       
                      },
                      child: Text("Add")),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        height: width < 600 ? 60 : 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Create New Playlist",
              style:  width < 600 ? StyleForApp.tileDisc : StyleForApp.headingLarge,
            ),
            Icon(
              Icons.add,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  
}

import 'dart:async';


import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:v_music_player/provider/music_provider.dart';
import 'package:v_music_player/screens/screen_add_to_playlist.dart';
import 'package:v_music_player/style/style.dart';

import 'audio_model.dart';

class DatabaseFunctions {
  List<AudioModel> newPlaylist =[];
  final Box<List<dynamic>>? _allSongsBox = Hive.box("allSongsBox");
  List<String> images = [
    "assets/asset_image_4.jpg",
  ];

  static DatabaseFunctions? _db;
  DatabaseFunctions.getDatabase();

  factory DatabaseFunctions() {
    if (_db == null) {
      _db = DatabaseFunctions.getDatabase();
      return _db!;
    }
    return _db!;
  }

  void deleteKey(String key) {
    _allSongsBox!.delete(key);
  }

  // get songs by playlist name

  List<AudioModel> getSongs(playlistName) {
    final List<AudioModel> audioModelSongs =
        _allSongsBox!.get(playlistName)!.cast<AudioModel>();
    return audioModelSongs;
  }

  // insert songs by playlist name

  insertSongs(List<AudioModel> playlist, String playlistName) async {
    await _allSongsBox!.put(playlistName, playlist);
    return true;
  }

  // converting Audio Model into Audio
  List<Audio> AudioModelToAudio(List<AudioModel> audioModelSongs) {
    images.shuffle();
    List<Audio> audioSongs = audioModelSongs
        .map(
          (audioModel) => Audio.file(
            audioModel.path!,
            metas:
                Metas(album: audioModel.album, title: audioModel.title, extra: {
              "image": Container(
                width: 100,
                height: 100,
                child: QueryArtworkWidget(
                  artworkBorder: BorderRadius.circular(2),
                  type: ArtworkType.AUDIO,
                  id: audioModel.id!,
                  nullArtworkWidget: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      images[0],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              "id": audioModel.id,
              "duration": audioModel.duration
            }),
          ),
        )
        .toList();

    return audioSongs;
  }
// converting audio to myAudioModel

  List<AudioModel> audioToMyAudioModel(List<Audio> audioModelSongs) {
    return audioModelSongs
        .map((audioModel) => AudioModel(
            path: audioModel.path,
            album: audioModel.metas.album,
            title: audioModel.metas.title,
            id: audioModel.metas.extra!["id"],
            duration: audioModel.metas.extra!["duration"]))
        .toList();
  }

  // fetching all the keys

  List<String> getKeys() {
    final List<String> keys = _allSongsBox!.keys.toList().cast<String>();
    return keys;
  }

  // This is a function to add song to playlist and showing a snackbar confirmation

  Future <bool> addToPlaylist(
      {Audio? audioModel, String? playlistName, BuildContext? context}) async {
    final DatabaseFunctions dbl = DatabaseFunctions.getDatabase();

    //converting Audio into AudioModel inorder to add to the playlist

    AudioModel myAudioModelSong = AudioModel(
        path: audioModel!.path,
        album: audioModel.metas.album,
        title: audioModel.metas.title,
        id: audioModel.metas.extra!["id"],
        duration: audioModel.metas.extra!["duration"]);

    // getting all songs in the playlist from database

    List<AudioModel> playlistSongs = await dbl.getSongs(playlistName);

    // checks the adding song is currently in the playlist or not if exists we dont add else we add.

    if (isExists(playlistSongs, myAudioModelSong)) {
      // confirms the playlist name is not Recent Songs to avoid showing snackbar
      // for adding every song that ever played

      if (playlistName != "Recent Songs") {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text("Song already exists"),
        ));

        // confirms the playlist name is Recent Songs and deletes the old entry and adds the
        // new entry.

      } else if (playlistName == "Recent Songs") {
        playlistSongs
            .removeWhere((element) => element.id == myAudioModelSong.id);
        playlistSongs.add(myAudioModelSong);
        await _allSongsBox!.put(playlistName, playlistSongs);
      }
      if (playlistName == "Favorites") {
        Navigator.of(context!).pop();
      }

      //  if song is not existent in playlist we simply add the song to list
      // and replace the list in database with current list
    } else {
      playlistSongs.add(AudioModel(
          path: audioModel.path,
          album: audioModel.metas.album,
          title: audioModel.metas.title,
          id: audioModel.metas.extra!["id"],
          duration: audioModel.metas.extra!["duration"]));
      await _allSongsBox!.put(playlistName, playlistSongs);

      // confirms the playlist name is not Recent Songs so that we can avoid
      // showing snackbar to every song added to the Recent songs
      //
      if (playlistName != "Recent Songs") {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text("Song added to '$playlistName'"),
        ));
      }

      // avoids the screen popping issue when we add song to favorites from the
      // playing screen as welll as when adding song to Recent songs from now playing screen

      if (playlistName != "Recent Songs") {
        Navigator.of(context!).pop();
      }
    }
    return true;
  }

  bool isExists(playlistSongs, myAudioModelSong) {
    if (playlistSongs!.length != 0) {
      final List<AudioModel> songs = playlistSongs!
          .where((element) => element.id == myAudioModelSong!.id)
          .toList();
      if (songs.length == 0) {
        return false;
      } else
        return true;
    } else
      return false;
  }

  Timer? _timer;

  // show dialogue function for adding to playlist and favorites
  // this shows a dialog box when user taps on the elipsis icon
  // it gives two options add to playlist and add to favorites
  // when pressed on either options we call add to playlist function

  void addToPlaylistOrFavorites({BuildContext? context, Audio? audioModel}) {
    showDialog(
        context: context!,
        builder: (context) => AlertDialog(
              titlePadding: EdgeInsets.all(8),
              backgroundColor: Colors.transparent,
              title: Container(
                 decoration: BoxDecoration(
              color:Colors.black
            ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pop();

                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: AddToPlaylistScreen(audioModel)));
                      },
                      title: Text(
                        "Add to playlist",
                        style: StyleForApp.tileDisc,
                      ),
                      trailing: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        {
                          if (_timer != null) {
                            _timer!.cancel();
                          }
                          _timer = Timer(Duration(milliseconds: 300), () {
                         Provider.of<MusicProvider>(context, listen: false).   addToPlaylist(
                                audioModel, context, "Favorites");
                          });
                        }
                        ;
                      },
                      title: Text(
                        "Add to Favorites",
                        style: StyleForApp.tileDisc,
                      ),
                      trailing: Icon(
                        FontAwesomeIcons.heart,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  deleteFromPlaylist(List<Audio> audioModelSongs, Audio audioModel,
      String playlistName) async {
    List<AudioModel> myAudioModelSongs = audioToMyAudioModel(audioModelSongs);
    myAudioModelSongs
        .removeWhere((element) => element.id == audioModel.metas.extra!['id']);
    await insertSongs(myAudioModelSongs, playlistName);
    return true;
  }

  void addToPlaylistIndividually(
      {Audio? audioModel, String? playlistName, BuildContext? context}) async {
    final DatabaseFunctions dbl = DatabaseFunctions.getDatabase();

    //converting Audio into AudioModel inorder to add to the playlist

    AudioModel myAudioModelSong = AudioModel(
        path: audioModel!.path,
        album: audioModel.metas.album,
        title: audioModel.metas.title,
        id: audioModel.metas.extra!["id"],
        duration: audioModel.metas.extra!["duration"]);

    // getting all songs in the playlist from database

    List<AudioModel> playlistSongs = await dbl.getSongs(playlistName);

    // checks the adding song is currently in the playlist or not if exists we dont add else we add.

    if (isExists(playlistSongs, myAudioModelSong)) {
      // confirms the playlist name is not Recent Songs to avoid showing snackbar
      // for adding every song that ever played

      if (playlistName != "Recent Songs") {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text("Song already exists"),
        ));

        // confirms the playlist name is Recent Songs and deletes the old entry and adds the
        // new entry.

      } else if (playlistName == "Recent Songs") {
        playlistSongs
            .removeWhere((element) => element.id == myAudioModelSong.id);
        playlistSongs.add(myAudioModelSong);
        await _allSongsBox!.put(playlistName, playlistSongs);
      }

      //  if song is not existent in playlist we simply add the song to list
      // and replace the list in database with current list
    } else {
      playlistSongs.add(AudioModel(
          path: audioModel.path,
          album: audioModel.metas.album,
          title: audioModel.metas.title,
          id: audioModel.metas.extra!["id"],
          duration: audioModel.metas.extra!["duration"]));
      await _allSongsBox!.put(playlistName, playlistSongs);

      // confirms the playlist name is not Recent Songs so that we can avoid
      // showing snackbar to every song added to the Recent songs
      //

    }

    // avoids the screen popping issue when we add song to favorites from the
    // playing screen as welll as when adding song to Recent songs from now playing screen
  }

  deleteFromPlaylistFromPlaylistScreen(
      Audio audioModel, String playlistName) async {
    List<AudioModel> myAudioModelSongs = getSongs(playlistName);

    myAudioModelSongs
        .removeWhere((element) => element.id == audioModel.metas.extra!['id']);
    await insertSongs(myAudioModelSongs, playlistName);
    return true;
  }



  Future<bool> isUnique(String keyword) async {
    int flag = 0;
    List<String> alreadyPlaylists =
        await _allSongsBox!.keys.cast<String>().toList();
    for (String playlist in alreadyPlaylists) {
      if (playlist == keyword) {
        flag = 1;
      }
    }
    if (flag == 1) {
      return false;
    } else
      return true;
  }

  Future<bool> putIt(context, keyword) async {
    bool isItUnique = await isUnique(keyword);
    if (keyword.isNotEmpty && isItUnique) {
      final newPlaylistName = keyword;
      await _allSongsBox!.put(newPlaylistName, newPlaylist);
      
     
      
      final snackBar = SnackBar(
          content: Text("New playlist named '${keyword}' added."));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
     keyword= "";
      
      Navigator.of(context).pop();
    } else {
      
      final snackBar = SnackBar(
          content:
              Text("Playlist name either exists or empty"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      
    }
    return true;
  }

  
}

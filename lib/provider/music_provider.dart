



import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:v_music_player/data_base/audio_model.dart';
import 'package:v_music_player/data_base/database_functions.dart';

class MusicProvider with ChangeNotifier{
  DatabaseFunctions db = DatabaseFunctions.getDatabase();
   void createPlaylist(BuildContext context ,String keyword) async{
    await db.putIt(context, keyword);
    notifyListeners();
   }

  List<String> getPlaylistNames(){
    return db.getKeys();

  }

  void deletePlaylist(playlistName){
    db.deleteKey(playlistName);
    notifyListeners();
  }

  void insertSongs(playlist, playlistName){
    db.insertSongs(playlist, playlistName);
    notifyListeners();

  }

  List<Audio> getSongs (playlistName) {
  List<AudioModel> audioSongs =  db.getSongs(playlistName);
  return db.AudioModelToAudio(audioSongs);
  }

  void addToPlaylistIndividually(audioModel, playlistName, context){
    db.addToPlaylistIndividually(audioModel: audioModel, playlistName: playlistName, context: context);
    notifyListeners();
  }

Future<bool> deleteFromPlaylist (audioModel, playlistName) async{
 await  db.deleteFromPlaylistFromPlaylistScreen(audioModel, playlistName);
   notifyListeners();
   return true;
 }

Future <bool> deleteSongFromPlaylist (audioModelSongs,audioModel, playlistName)async{
  await db.deleteFromPlaylist(audioModelSongs, audioModel, playlistName);
  notifyListeners();
  return true;
}

Future <bool> addToPlaylist (audioModel, context, playlistName) async{
  
  await db.addToPlaylist(audioModel: audioModel, context: context , playlistName: playlistName);
  notifyListeners();
  return true;
}





}
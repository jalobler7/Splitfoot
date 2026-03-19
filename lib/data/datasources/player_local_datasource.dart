import 'package:hive/hive.dart';
import '../models/player_model.dart';

class PlayerLocalDataSource {
  final Box<PlayerModel> _box = Hive.box<PlayerModel>('players');

  List<PlayerModel> getAllPlayers() {
    return _box.values.toList();
  }

  Future<void> addPlayer(PlayerModel player) async {
    await _box.put(player.id, player);
  }

  Future<void> deletePlayer(String id) async {
    await _box.delete(id);
  }
}
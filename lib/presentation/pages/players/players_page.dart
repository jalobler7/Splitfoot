import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/datasources/player_local_datasource.dart';
import '../../../data/models/player_model.dart';
import '../../../widgets/players/player_form_dialog.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final PlayerLocalDataSource _dataSource = PlayerLocalDataSource();
  final TextEditingController _searchController = TextEditingController();

  List<PlayerModel> _allPlayers = [];
  List<PlayerModel> _filteredPlayers = [];

  String _searchQuery = '';
  final Set<String> _selectedPositions = {};
  String? _selectedSport;

  static const List<String> _sportOptions = [
    'Futsal',
    'Fut7',
    'Fut11',
  ];

  List<String> get _availablePositions {
    final playersBySport = _selectedSport == null
        ? _allPlayers
        : _allPlayers
            .where((player) => player.sport == _selectedSport)
            .toList();

    final positions = playersBySport.map((player) => player.position).toSet();
    final orderedPositions = positions.toList()..sort();
    return orderedPositions;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadPlayers();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _searchQuery) return;

    setState(() {
      _searchQuery = query;
      _filteredPlayers = _applyFilters();
    });
  }

  void _loadPlayers() {
    final players = _dataSource.getAllPlayers();

    setState(() {
      _allPlayers = players;
      _syncSelectedPositionsWithAvailable();
      _filteredPlayers = _applyFilters();
    });
  }

  List<PlayerModel> _applyFilters() {
    return _allPlayers.where((player) {
      final matchesName = _searchQuery.isEmpty ||
          player.name.toLowerCase().contains(_searchQuery);
      final matchesSport =
          _selectedSport == null || player.sport == _selectedSport;
      final matchesPosition = _selectedPositions.isEmpty ||
          _selectedPositions.contains(player.position);

      return matchesName && matchesSport && matchesPosition;
    }).toList();
  }

  void _syncSelectedPositionsWithAvailable() {
    final available = _availablePositions.toSet();
    _selectedPositions.removeWhere((position) => !available.contains(position));
  }

  void _onSportChanged(String? sport) {
    if (_selectedSport == sport) return;

    setState(() {
      _selectedSport = sport;
      _syncSelectedPositionsWithAvailable();
      _filteredPlayers = _applyFilters();
    });
  }

  void _togglePositionFilter(String position) {
    setState(() {
      if (_selectedPositions.contains(position)) {
        _selectedPositions.remove(position);
      } else {
        _selectedPositions.add(position);
      }
      _filteredPlayers = _applyFilters();
    });
  }

  void _openAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (_) => PlayerFormDialog(
        onSave: (player) async {
          await _dataSource.addPlayer(player);
          _loadPlayers();
        },
      ),
    );
  }

  void _openEditPlayerDialog(PlayerModel player) {
    showDialog(
      context: context,
      builder: (_) => PlayerFormDialog(
        initialPlayer: player,
        onSave: (updatedPlayer) async {
          await _dataSource.updatePlayer(updatedPlayer);
          _loadPlayers();
        },
      ),
    );
  }

  Future<void> _removePlayer(String playerId) async {
    await _dataSource.deletePlayer(playerId);
    if (!mounted) return;
    _loadPlayers();
  }

  Future<void> _confirmDeletePlayer(PlayerModel player) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text('Tem certeza que deseja excluir este jogador?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _removePlayer(player.id);
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogadores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPlayerDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              value: _selectedSport,
              decoration: const InputDecoration(
                labelText: 'Esporte',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ..._sportOptions.map(
                  (sport) => DropdownMenuItem<String?>(
                    value: sport,
                    child: Text(sport),
                  ),
                ),
              ],
              onChanged: _onSportChanged,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Posicoes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            _availablePositions.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Nenhuma posicao disponivel para o filtro'),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availablePositions.map((position) {
                        return ChoiceChip(
                          label: Text(position),
                          selected: _selectedPositions.contains(position),
                          onSelected: (_) => _togglePositionFilter(position),
                        );
                      }).toList(),
                    ),
                  ),
            const SizedBox(height: 12),
            Expanded(
              child: _allPlayers.isEmpty
                  ? const Center(
                      child: Text('Nenhum jogador cadastrado'),
                    )
                  : _filteredPlayers.isEmpty
                      ? const Center(
                          child: Text('Nenhum jogador encontrado'),
                        )
                      : ListView.separated(
                          itemCount: _filteredPlayers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final player = _filteredPlayers[index];

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      child: Text(player.overall.toString()),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            player.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text('Esporte: ${player.sport}'),
                                          Text('Posicao: ${player.position}'),
                                          Text('Ataque: ${player.attack}'),
                                          Text('Defesa: ${player.defense}'),
                                          Text('Folego: ${player.stamina}'),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _openEditPlayerDialog(player),
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _confirmDeletePlayer(player),
                                          icon:
                                              const Icon(Icons.delete_outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

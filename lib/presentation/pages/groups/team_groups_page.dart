import 'package:divide_time/app/routes/app_routes.dart';
import 'package:divide_time/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/datasources/team_group_local_datasource.dart';
import '../../../data/models/team_group_model.dart';
import '../../../widgets/groups/group_form_dialog.dart';

class TeamGroupsPage extends StatefulWidget {
  const TeamGroupsPage({super.key});

  @override
  State<TeamGroupsPage> createState() => _TeamGroupsPageState();
}

class _TeamGroupsPageState extends State<TeamGroupsPage> {
  final TeamGroupLocalDataSource _groupDataSource = TeamGroupLocalDataSource();

  List<TeamGroupModel> _groups = [];
  String? _deletingGroupId;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _groups = _groupDataSource.getAllGroups();
    });
  }

  Future<void> _openCreateGroupDialog() async {
    await showDialog<TeamGroupModel>(
      context: context,
      builder: (_) => GroupFormDialog(
        onSave: (group) async {
          await _groupDataSource.addGroup(group);
          _loadGroups();
        },
      ),
    );
  }

  Future<void> _openEditGroupDialog(TeamGroupModel group) async {
    await showDialog<TeamGroupModel>(
      context: context,
      builder: (_) => GroupFormDialog(
        initialGroup: group,
        onSave: (updatedGroup) async {
          await _groupDataSource.updateGroup(updatedGroup);
          _loadGroups();
        },
      ),
    );
  }

  Future<void> _confirmDeleteGroup(TeamGroupModel group) async {
    final deletedPlayers = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF14191B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Excluir grupo',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.danger,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Todos os jogadores linkados a esse grupo serão eliminados. Deseja continuar?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                group.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _deletingGroupId == group.id
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.55),
                disabledForegroundColor: Colors.white70,
              ),
              onPressed: _deletingGroupId == group.id
                  ? null
                  : () async {
                      setState(() {
                        _deletingGroupId = group.id;
                      });
                      setDialogState(() {});

                      try {
                        final removedPlayers = await _groupDataSource
                            .deleteGroupCascade(group.id);
                        if (!mounted) return;
                        _loadGroups();
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(removedPlayers);
                        }
                      } catch (_) {
                        if (!mounted) return;
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Nao foi possivel excluir o grupo. Tente novamente.',
                            ),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _deletingGroupId = null;
                          });
                        }
                      }
                    },
              child: _deletingGroupId == group.id
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Excluir'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || deletedPlayers == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deletedPlayers == 0
              ? 'Grupo excluido com sucesso.'
              : 'Grupo excluido com $deletedPlayers jogador(es) removido(s).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateGroupDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        label: const Text('Criar grupo'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1510),
              AppColors.background,
              Color(0xFF0E1217),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
            child: Column(
              children: [
                Row(
                  children: [
                    _TopIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.go(AppRoutes.home),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meus grupos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Organize atletas por time ou grupo.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _groups.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          itemCount: _groups.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final group = _groups[index];
                            final playersCount = _groupDataSource.countPlayersForGroup(group.id);
                            return _GroupCard(
                              group: group,
                              playersCount: playersCount,
                              onEdit: () => _openEditGroupDialog(group),
                              onDelete: () => _confirmDeleteGroup(group),
                              isDeleting: _deletingGroupId == group.id,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.playersCount,
    required this.onEdit,
    required this.onDelete,
    this.isDeleting = false,
  });

  final TeamGroupModel group;
  final int playersCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161C1F), Color(0xFF111618)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.folder_copy_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$playersCount atletas deste grupo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isDeleting ? null : onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: isDeleting ? null : onDelete,
            icon: isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.danger),
                    ),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF14191B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_copy_rounded, color: AppColors.primary, size: 44),
            SizedBox(height: 16),
            Text(
              'Nenhum grupo cadastrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Crie um grupo para organizar seus atletas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

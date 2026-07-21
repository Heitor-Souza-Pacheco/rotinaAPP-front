import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/time_of_day_x.dart';
import '../providers/auth_provider.dart';
import '../providers/habitos_provider.dart';
import '../providers/perfil_provider.dart';
import '../widgets/status_views.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  /// Fusos comuns oferecidos ao usuário.
  static const _fusos = [
    'America/Sao_Paulo',
    'America/Manaus',
    'America/Rio_Branco',
    'America/Belem',
    'America/Fortaleza',
    'America/Recife',
    'America/Bahia',
    'America/Cuiaba',
    'America/Campo_Grande',
    'America/Noronha',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerfilProvider>().carregar();
    });
  }

  Future<void> _editarFuso(PerfilProvider provider) async {
    final atual = provider.usuario?.fusoHorario;
    final opcoes = {..._fusos, ?atual}.toList();
    final escolhido = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text('Fuso horário',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            ...opcoes.map((f) => ListTile(
                  title: Text(f.replaceAll('_', ' ')),
                  trailing: f == atual
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, f),
                )),
          ],
        ),
      ),
    );
    if (escolhido != null && escolhido != atual) {
      await _salvar(provider, fusoHorario: escolhido);
    }
  }

  Future<void> _editarHorario(
    PerfilProvider provider, {
    required bool reset,
  }) async {
    final usuario = provider.usuario;
    final inicial = reset
        ? (usuario?.horarioReset ?? const TimeOfDay(hour: 0, minute: 0))
        : (usuario?.horarioNotificacao ??
            const TimeOfDay(hour: 8, minute: 0));
    final escolhido = await showTimePicker(
      context: context,
      initialTime: inicial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (escolhido == null) return;
    if (reset) {
      await _salvar(provider, horarioReset: escolhido);
    } else {
      await _salvar(provider, horarioNotificacao: escolhido);
    }
  }

  Future<void> _salvar(
    PerfilProvider provider, {
    String? fusoHorario,
    TimeOfDay? horarioReset,
    TimeOfDay? horarioNotificacao,
  }) async {
    try {
      await provider.atualizar(
        fusoHorario: fusoHorario,
        horarioReset: horarioReset,
        horarioNotificacao: horarioNotificacao,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente para acessar '
            'seus hábitos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    context.read<HabitosProvider>().limpar();
    context.read<PerfilProvider>().limpar();
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PerfilProvider provider) {
    if (provider.loading && provider.usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.erro != null && provider.usuario == null) {
      return ErrorStateView(
        message: provider.erro!,
        onRetry: provider.carregar,
      );
    }
    final usuario = provider.usuario;
    if (usuario == null) {
      return const SizedBox.shrink();
    }

    final iniciais = usuario.nome.trim().isEmpty
        ? '?'
        : usuario.nome
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();

    return RefreshIndicator(
      onRefresh: provider.carregar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      iniciais,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(usuario.nome,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(usuario.email,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Preferências'),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingTile(
                icon: Icons.public_rounded,
                iconColor: AppColors.primary,
                title: 'Fuso horário',
                value: usuario.fusoHorario.replaceAll('_', ' '),
                onTap: provider.saving ? null : () => _editarFuso(provider),
              ),
              const _Divider(),
              _SettingTile(
                icon: Icons.restart_alt_rounded,
                iconColor: AppColors.secondary,
                title: 'Horário de reset diário',
                value: usuario.horarioReset != null
                    ? TimeParsing.display(usuario.horarioReset!)
                    : '00:00',
                onTap: provider.saving
                    ? null
                    : () => _editarHorario(provider, reset: true),
              ),
              const _Divider(),
              _SettingTile(
                icon: Icons.notifications_active_rounded,
                iconColor: AppColors.accent,
                title: 'Lembrete diário',
                value: usuario.horarioNotificacao != null
                    ? TimeParsing.display(usuario.horarioNotificacao!)
                    : 'Definir',
                onTap: provider.saving
                    ? null
                    : () => _editarHorario(provider, reset: false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'O reset diário define quando um novo dia começa para seus '
              'hábitos. O lembrete envia uma notificação para você não '
              'esquecer da sua rotina.',
              style: TextStyle(
                  color: AppColors.textFaint, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 64, endIndent: 16);
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textFaint),
        ],
      ),
      onTap: onTap,
    );
  }
}

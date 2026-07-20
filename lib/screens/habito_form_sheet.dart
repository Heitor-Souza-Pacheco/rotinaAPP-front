import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/habito.dart';
import '../providers/habitos_provider.dart';
import '../widgets/primary_button.dart';

/// Bottom sheet para criar ou editar um hábito.
class HabitoFormSheet extends StatefulWidget {
  final Habito? habito;
  const HabitoFormSheet({super.key, this.habito});

  static Future<bool?> mostrar(BuildContext context, {Habito? habito}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitoFormSheet(habito: habito),
    );
  }

  @override
  State<HabitoFormSheet> createState() => _HabitoFormSheetState();
}

class _HabitoFormSheetState extends State<HabitoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descCtrl;
  bool _saving = false;

  bool get _editando => widget.habito != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.habito?.titulo ?? '');
    _descCtrl = TextEditingController(text: widget.habito?.descricao ?? '');
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final provider = context.read<HabitosProvider>();
    final titulo = _tituloCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    try {
      if (_editando) {
        await provider.editar(widget.habito!.id,
            titulo: titulo, descricao: desc);
      } else {
        await provider.criar(titulo, desc);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Text(
                _editando ? 'Editar hábito' : 'Novo hábito',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tituloCtrl,
                textCapitalization: TextCapitalization.sentences,
                autofocus: !_editando,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ex.: Beber 2L de água',
                  prefixIcon: Icon(Icons.bolt_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe um título'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Adicione um detalhe ou motivação',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _editando ? 'Salvar alterações' : 'Criar hábito',
                icon: _editando ? Icons.check_rounded : Icons.add_rounded,
                loading: _saving,
                onPressed: _saving ? null : _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

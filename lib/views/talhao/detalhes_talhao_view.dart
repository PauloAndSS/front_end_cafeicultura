// lib/views/talhao/detalhes_talhao_view.dart
import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/talhao.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/detalhes_talhao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'package:provider/provider.dart';

class DetalhesTalhaoView extends StatefulWidget {
  final Talhao talhao;

  const DetalhesTalhaoView({super.key, required this.talhao});

  @override
  State<DetalhesTalhaoView> createState() => _DetalhesTalhaoViewState();
}

class _DetalhesTalhaoViewState extends State<DetalhesTalhaoView> {
  final _viewModel = DetalhesTalhaoViewModel();

  Future<void> _confirmarEncerramento(BuildContext context) async {
    final DateTime? dataFimEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data de encerramento do talhão',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF67835C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataFimEscolhida == null) return;

    if (!mounted) return;

    // Confirmação extra via Dialog
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar Talhão'),
        content: Text(
          'Deseja realmente encerrar o talhão "${widget.talhao.nome}" na data ${dataFimEscolhida.day.toString().padLeft(2, '0')}/${dataFimEscolhida.month.toString().padLeft(2, '0')}/${dataFimEscolhida.year}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Encerrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _viewModel.encerrar(
        widget.talhao.id!,
        dataFimEscolhida,
      );

      if (!mounted) return;

      if (sucesso == true) {
        // Atualiza a lista de talhões ativos na tela anterior
        final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
        if (propriedadesVM.idPropriedadeSelecionada != null) {
          context.read<TalhoesViewModel>().carregarTalhoes(
            propriedadesVM.idPropriedadeSelecionada!,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talhão encerrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Volta para a tela anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _viewModel.mensagemErro ?? 'Erro ao encerrar talhão.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataInicioFormatada = 
        '${widget.talhao.dataInicio.day.toString().padLeft(2, '0')}/${widget.talhao.dataInicio.month.toString().padLeft(2, '0')}/${widget.talhao.dataInicio.year}';

    final dataFimFormatada = widget.talhao.dataFim != null
        ? '${widget.talhao.dataFim!.day.toString().padLeft(2, '0')}/${widget.talhao.dataFim!.month.toString().padLeft(2, '0')}/${widget.talhao.dataFim!.year}'
        : null;

    final variedadesTexto = widget.talhao.variedadesCafe != null && widget.talhao.variedadesCafe!.isNotEmpty
        ? widget.talhao.variedadesCafe!.map((v) => v.descricao).join(', ')
        : 'Nenhuma variedade.';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.talhao.nome,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF67835C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Informações do Talhão',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF67835C),
                            ),
                          ),
                          if (widget.talhao.arquivado == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Arquivado',
                                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Nome:', widget.talhao.nome),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Espécie:', 
                        widget.talhao.especie.isNotEmpty 
                            ? widget.talhao.especie[0].toUpperCase() + widget.talhao.especie.substring(1) 
                            : 'Não informada',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Variedades de Café:', variedadesTexto),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Quantidade de Pés:',
                        '${widget.talhao.qtdPeCafe}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Tamanho:',
                        '${widget.talhao.tamanho.valor} ${widget.talhao.tamanho.medida.nomeExibicao}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Data de Início:', dataInicioFormatada),
                      if (dataFimFormatada != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow('Data de Encerramento:', dataFimFormatada),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 👇 Verifica se o talhão está arquivado para exibir o aviso ou o botão de encerramento
                if (widget.talhao.arquivado == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este talhão já foi encerrado e não pode mais ser modificado.',
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _viewModel.isLoading
                          ? 'Encerrando...'
                          : 'Encerrar Talhão',
                      onPressed: _viewModel.isLoading
                          ? null
                          : () => _confirmarEncerramento(context),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
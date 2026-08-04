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

  void _onSucesso(String mensagem) {
    final propriedadesVM = context.read<PropriedadesUsuarioViewModel>();
    if (propriedadesVM.idPropriedadeSelecionada != null) {
      context.read<TalhoesViewModel>().carregarTalhoes(
        propriedadesVM.idPropriedadeSelecionada!,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }

  void _onErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _confirmarEncerramento(BuildContext context) async {
    final DateTime hoje = DateTime.now();

    final DateTime? dataFimEscolhida = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: widget.talhao.dataInicio,
      lastDate: hoje,
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
        _onSucesso('Talhão encerrado com sucesso!');
      } else {
        _onErro(_viewModel.mensagemErro ?? 'Erro ao encerrar talhão.');
      }
    }
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Talhão'),
        content: Text(
          'Tem certeza que deseja excluir permanentemente o talhão "${widget.talhao.nome}"?\n\nEsta ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final sucesso = await _viewModel.excluir(widget.talhao.id!);

      if (!mounted) return;

      if (sucesso == true) {
        _onSucesso('Talhão excluído com sucesso!');
      } else {
        _onErro(_viewModel.mensagemErro ?? 'Erro ao excluir talhão.');
      }
    }
  }

  // 👇 Método reutilizável para seções que serão implementadas futuramente
  Widget _buildSecaoEmBreve(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Em breve...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool estaEncerrado = widget.talhao.dataFim != null || widget.talhao.arquivado == true;

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
                          if (estaEncerrado)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Encerrado',
                                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Nome:', widget.talhao.nome),
                      const SizedBox(height: 12),
                      _buildInfoRow('Espécie:', widget.talhao.especieFormatada),
                      const SizedBox(height: 12),
                      _buildInfoRow('Variedades de Café:', widget.talhao.variedadesTexto),
                      const SizedBox(height: 12),
                      _buildInfoRow('Quantidade de Pés:', widget.talhao.qtdPeCafeFormatada),
                      const SizedBox(height: 12),
                      _buildInfoRow('Tamanho:', widget.talhao.tamanhoFormatado),
                      const SizedBox(height: 12),
                      _buildInfoRow('Data de Início:', widget.talhao.dataInicioFormatada),
                      if (widget.talhao.dataFimFormatada != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow('Data de Encerramento:', widget.talhao.dataFimFormatada!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (estaEncerrado)
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

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _viewModel.isLoading ? 'Aguarde...' : 'Excluir Talhão',
                    onPressed: _viewModel.isLoading ? null : () => _confirmarExclusao(context),
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // 👇 Seção de Atividades do Talhão em breve
                _buildSecaoEmBreve('Atividades :'),
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
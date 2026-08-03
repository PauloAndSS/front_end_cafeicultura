import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/safra/safra.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedade/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';
import 'package:provider/provider.dart';

class SafraViewPage extends StatefulWidget {
  const SafraViewPage({super.key});

  @override
  State<SafraViewPage> createState() => _SafraViewPageState();
}

class _SafraViewPageState extends State<SafraViewPage> {
  int? _ultimaPropriedadeCarregada;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final propriedadesVm = context.watch<PropriedadesUsuarioViewModel>();
    final idPropriedade = propriedadesVm.idPropriedadeSelecionada;

    if (idPropriedade != null && idPropriedade != _ultimaPropriedadeCarregada) {
      _ultimaPropriedadeCarregada = idPropriedade;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        context.read<SafraViewModel>().carregarDadosDaPropriedade(idPropriedade);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SafraViewModel>();
    final propriedadesVm = context.watch<PropriedadesUsuarioViewModel>();

    String? nomePropriedade;
    for (final propriedade in propriedadesVm.propriedades) {
      if (propriedade.id == propriedadesVm.idPropriedadeSelecionada) {
        nomePropriedade = propriedade.nome;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Safras e relatórios'),
        backgroundColor: const Color(0xFF8FA67E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (propriedadesVm.idPropriedadeSelecionada != null) {
            await viewModel.carregarDadosDaPropriedade(
              propriedadesVm.idPropriedadeSelecionada!,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seleção da safra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF67835C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nomePropriedade ?? 'Selecione uma propriedade para ver as safras.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Safra>(
                        value: viewModel.safraSelecionada,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Safra selecionada',
                        ),
                        items: viewModel.safras
                            .map(
                              (safra) => DropdownMenuItem<Safra>(
                                value: safra,
                                child: Text(
                                  safra.nome.isNotEmpty
                                      ? safra.nome
                                      : 'Safra ${safra.id ?? 'sem id'}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: viewModel.safras.isEmpty
                            ? null
                            : (Safra? safra) {
                                if (safra != null) {
                                  viewModel.selecionarSafra(safra);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.mensagemErro != null)
                Column(
                  children: [
                    _buildMessageCard(viewModel.mensagemErro!),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        if (propriedadesVm.idPropriedadeSelecionada != null) {
                          viewModel.carregarDadosDaPropriedade(
                            propriedadesVm.idPropriedadeSelecionada!,
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                )
              else if (viewModel.safras.isEmpty)
                _buildEmptyState()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewModel.safraSelecionada != null)
                      _buildSafraSummary(viewModel.safraSelecionada!),
                    const SizedBox(height: 16),
                    const Text(
                      'Relatório da safra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF67835C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (viewModel.isLoadingRelatorio)
                      const Center(child: CircularProgressIndicator())
                    else if (viewModel.relatorio.isEmpty)
                      _buildEmptyReportState()
                    else
                      ...viewModel.relatorio.map(_buildEventCard).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafraSummary(Safra safra) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safra.nome.isNotEmpty ? safra.nome : 'Safra ${safra.id ?? 'sem identificador'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(safra.periodoTexto),
            const SizedBox(height: 4),
            Text('Status: ${safra.status.isNotEmpty ? safra.status : (safra.ativa ? 'Ativa' : 'Inativa')}'),
            const SizedBox(height: 4),
            Text('Descrição: ${safra.descricao.isNotEmpty ? safra.descricao : 'Sem descrição informada'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(SafraEvento evento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evento.descricao.isNotEmpty ? evento.descricao : 'Evento da safra',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (evento.tipo.isNotEmpty)
              Text('Tipo: ${evento.tipo}'),
            if (evento.data.isNotEmpty)
              Text('Data: ${evento.data}'),
            if (evento.status.isNotEmpty)
              Text('Status: ${evento.status}'),
            if (evento.responsavel.isNotEmpty)
              Text('Responsável: ${evento.responsavel}'),
            if (evento.valor.isNotEmpty)
              Text('Valor: ${evento.valor}'),
            if (evento.quantidade.isNotEmpty)
              Text('Quantidade: ${evento.quantidade}'),
            if (evento.observacao.isNotEmpty)
              Text('Observação: ${evento.observacao}'),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.grass, size: 44, color: Color(0xFF8FA67E)),
            const SizedBox(height: 12),
            const Text('Nenhuma safra cadastrada para esta propriedade.'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReportState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.description_outlined, size: 44, color: Color(0xFF8FA67E)),
            const SizedBox(height: 12),
            const Text('Ainda não há eventos registrados para esta safra.'),
          ],
        ),
      ),
    );
  }
}

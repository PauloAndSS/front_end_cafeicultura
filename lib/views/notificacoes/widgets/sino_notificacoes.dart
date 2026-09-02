import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/notificacoes/notificacoes_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/notificacoes/notificacoes_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:provider/provider.dart';

class SinoNotificacoes extends StatelessWidget {
  const SinoNotificacoes({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificacoesViewModel>();
    final geracaoDoCache = context.watch<AtividadesMudaram>().geracao;
    final idPropriedade = context
        .watch<PropriedadesUsuarioViewModel>()
        .idPropriedadeSelecionada;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (idPropriedade != null) viewModel.garantirCarregado(idPropriedade);

      viewModel.sincronizarCom(geracaoDoCache);
    });

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: 26,
          ),
          tooltip: 'Notificações',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificacoesView()),
          ),
        ),
        if (viewModel.quantidadeNaoLidas > 0)
          Positioned(
            top: 6,
            right: 4,
            child: _ContadorNaoLidas(
              quantidade: viewModel.quantidadeNaoLidas,
            ),
          ),
      ],
    );
  }
}

class _ContadorNaoLidas extends StatelessWidget {
  final int quantidade;

  const _ContadorNaoLidas({required this.quantidade});

  String get _texto => quantidade > 99 ? '99+' : '$quantidade';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppCores.aviso,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppCores.verdeSecundario, width: 1.5),
      ),
      child: Text(
        _texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      ),
    );
  }
}

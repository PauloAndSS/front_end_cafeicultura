import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/atividades/atividades_mudaram.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/insumos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/navegacao_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/armazem/insumos_tab_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/em_desenvolvimento_widget.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/reinicio_de_secao.dart';
import 'package:provider/provider.dart';

class ArmazemView extends StatefulWidget {
  const ArmazemView({super.key});

  @override
  State<ArmazemView> createState() => _ArmazemViewState();
}

class _ArmazemViewState extends State<ArmazemView>
    with
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin,
        ReinicioDeSecaoMixin {
  final _viewModel = InsumosViewModel();

  int? _idPropriedade;

  late final TabController _abas;

  @override
  bool get wantKeepAlive => true;

  @override
  SecaoPrincipal get secaoDoReinicio => SecaoPrincipal.armazem;

  @override
  void aoReiniciarSecao() {
    _abas.index = 0;
  }

  @override
  void initState() {
    super.initState();
    _abas = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final idPropriedade =
        context.watch<PropriedadesUsuarioViewModel>().idPropriedadeSelecionada;

    _idPropriedade = idPropriedade;

    _viewModel.sincronizarCom(context.watch<AtividadesMudaram>().geracao);

    if (idPropriedade == null) return;
    if (_viewModel.insumosCarregadosDe(idPropriedade)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.carregarInsumos(idPropriedade: idPropriedade);
    });
  }

  @override
  void dispose() {
    _abas.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    observarReinicioDeSecao(context);

    return Scaffold(
      backgroundColor: AppCores.fundo,
      body: SafeArea(
        child: Column(
          children: [
            BarraDeAbas(
              controller: _abas,
              abas: const [
                Tab(text: 'Insumos'),
                Tab(text: 'Café'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _abas,
                children: [
                  InsumosTabView(
                    viewModel: _viewModel,
                    idPropriedade: _idPropriedade,
                  ),
                  const EmDesenvolvimentoWidget(titulo: 'Estoque de Café'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

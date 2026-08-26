import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/insumos/insumos_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/views/armazem/insumos_tab_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/abas_padrao.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/em_desenvolvimento_widget.dart';

class ArmazemView extends StatefulWidget {
  const ArmazemView({super.key});

  @override
  State<ArmazemView> createState() => _ArmazemViewState();
}

class _ArmazemViewState extends State<ArmazemView>
    with AutomaticKeepAliveClientMixin {
  final _viewModel = InsumosViewModel();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewModel.insumosCarregados) return;

      _viewModel.carregarInsumos();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        body: SafeArea(
          child: Column(
            children: [
              const BarraDeAbas(
                abas: [
                  Tab(text: 'Insumos'),
                  Tab(text: 'Café'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    InsumosTabView(viewModel: _viewModel),
                    const EmDesenvolvimentoWidget(titulo: 'Estoque de Café'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

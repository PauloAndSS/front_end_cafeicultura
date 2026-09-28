import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/endereco.dart';
import 'package:frond_end_cafeicultura_mobile/utils/masks.dart';
import 'package:frond_end_cafeicultura_mobile/utils/validator.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/text_field.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/uf_dropdown.dart';

// Importe o seu serviço aqui
// import 'package:seu_app/services/service_viacep.dart';

class BlocoEndereco extends StatefulWidget {
  final TextEditingController controllerCep;
  final TextEditingController controllerLogradouro;
  final TextEditingController controllerBairro;
  final TextEditingController controllerCidade;

  final UF? uf;
  final ValueChanged<UF?> aoSelecionarUf;

  final String dicaLogradouro;
  final String dicaBairro;

  final bool Function()? exigirPreenchimento;

  const BlocoEndereco({
    super.key,
    required this.controllerCep,
    required this.controllerLogradouro,
    required this.controllerBairro,
    required this.controllerCidade,
    required this.uf,
    required this.aoSelecionarUf,
    this.exigirPreenchimento,
    this.dicaLogradouro = 'Rua, Avenida, número, complemento...',
    this.dicaBairro = 'Digite o bairro ou distrito',
  });

  @override
  State<BlocoEndereco> createState() => _BlocoEnderecoState();
}

class _BlocoEnderecoState extends State<BlocoEndereco> {
  final ServiceVIACEP _serviceViaCep = ServiceVIACEP();
  bool _buscandoCep = false;

  bool get _exigido => widget.exigirPreenchimento?.call() ?? true;

  String? _seExigido(String? Function(String?) validar, String? valor) {
    return _exigido ? validar(valor) : null;
  }

  @override
  void initState() {
    super.initState();
    widget.controllerCep.addListener(_aoMudarCep);
  }

  @override
  void dispose() {
    widget.controllerCep.removeListener(_aoMudarCep);
    super.dispose();
  }
  Future<void> _aoMudarCep() async {
    final cepLimpo = widget.controllerCep.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length == 8 && !_buscandoCep) {
      setState(() => _buscandoCep = true);

      try {
        final endereco = await _serviceViaCep.buscarCEP(cep: cepLimpo);

        if (endereco != null) {
          widget.controllerLogradouro.text = endereco.logradouro;
          widget.controllerBairro.text = endereco.bairro;
          widget.controllerCidade.text = endereco.localidade;
          _atualizarUfPelaSigla(endereco.uf);
        } else {
          // Opcional: Mostrar um SnackBar informando que o CEP não foi encontrado
        }
      } catch (e) {
        // Opcional: Lidar com erro de conexão
      } finally {
        setState(() => _buscandoCep = false);
      }
    }
  }

  /// Método auxiliar para converter a String da API ('ES') no tipo UF do seu app
  void _atualizarUfPelaSigla(String siglaApi) {
    // Como não tenho a implementação da sua classe/enum UF, aqui vai um exemplo genérico.
    // Supondo que UF seja um enum: enum UF { AC, AL, AM, ..., ES, ... }
    try {
      final ufEncontrada = UF.values.firstWhere(
        (uf) => uf.name.toUpperCase() == siglaApi.toUpperCase(),
      );
      widget.aoSelecionarUf(ufEncontrada);
    } catch (e) {
      // Caso a UF não seja encontrada, não faz nada
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CEP
        Stack(
          alignment: Alignment.centerRight,
          children: [
            CustomTextField(
              label: 'CEP',
              controller: widget.controllerCep,
              keyboardType: TextInputType.number,
              validator: (valor) => _seExigido(Validator.validarCEP, valor),
              inputFormatters: [AppMasks.cep],
              hintText: 'Digite o CEP (apenas números)',
            ),
            // Indicador de carregamento visual
            if (_buscandoCep)
              const Padding(
                padding: EdgeInsets.only(right: 16.0, top: 20), // Ajuste o top conforme o layout do CustomTextField
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        
        // Logradouro
        CustomTextField(
          label: 'Logradouro',
          controller: widget.controllerLogradouro,
          validator: (valor) => _seExigido(Validator.validarNome, valor),
          hintText: widget.dicaLogradouro,
        ),
        
        // Bairro/Distrito
        CustomTextField(
          label: 'Bairro/Distrito',
          controller: widget.controllerBairro,
          validator: (valor) => _seExigido(Validator.validarNome, valor),
          hintText: widget.dicaBairro,
        ),
        
        // Cidade e UF
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _campoCidade()),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: _campoUf()),
          ],
        ),
      ],
    );
  }

  Widget _campoCidade() => CustomTextField(
    label: 'Cidade',
    controller: widget.controllerCidade,
    validator: (valor) => _seExigido(Validator.validarNome, valor),
    hintText: 'Nome da cidade',
  );

  Widget _campoUf() => UfDropdown(
    value: widget.uf,
    onChanged: widget.aoSelecionarUf,
    validator: (valor) {
      if (!_exigido) return null;
      return valor == null ? 'Obrigatório' : null;
    },
  );
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ViewModels
import 'package:frond_end_cafeicultura_mobile/viewmodels/auth/session_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/propriedades/propriedades_usuario_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/talhao/talhao_propriedades_viewmodel.dart';
import 'package:frond_end_cafeicultura_mobile/viewmodels/safra/safra_viewmodel.dart';

// Telas de Destino
import 'package:frond_end_cafeicultura_mobile/views/pessoas/cadastrar_pessoa_view.dart';
// import 'package:frond_end_cafeicultura_mobile/views/pessoas/cadastrar_endereco_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/propriedade/cadastrar_propriedade_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/talhao/cadastrar_talhao_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/safra/safra_view_page.dart';

// 👇 1. CLASSE AUXILIAR PARA GUARDAR A PENDÊNCIA 👇
class PendenciaCadastro {
  final String mensagem;
  final String textoBotao;
  final Widget telaDestino;

  PendenciaCadastro({
    required this.mensagem,
    required this.textoBotao,
    required this.telaDestino,
  });
}

// 👇 2. FUNÇÃO GLOBAL QUE O SINO DE NOTIFICAÇÕES TAMBÉM VAI USAR 👇
PendenciaCadastro? verificarPendenciasDeCadastro(BuildContext context) {
  final sessionVM = context.watch<SessionViewModel>();
  final propriedadesVM = context.watch<PropriedadesUsuarioViewModel>();
  final talhoesVM = context.watch<TalhoesViewModel>();
  final safraVM = context.watch<SafraViewModel>();

  if (sessionVM.dadosProprietarioIncompletos) {
    return PendenciaCadastro(
      mensagem: 'Complete seus dados de proprietário para utilizar o sistema.',
      textoBotao: 'Continuar',
      telaDestino: const CadastrarPessoaView(),
    );
  } 
  else if (sessionVM.enderecoIncompleto) {
    return PendenciaCadastro(
      mensagem: 'Precisamos do seu endereço para continuar.',
      textoBotao: 'Continuar',
      telaDestino: const CadastrarPessoaView(), // Mude para CadastrarEnderecoView depois
    );
  } 
  else if (propriedadesVM.propriedades.isEmpty) {
    return PendenciaCadastro(
      mensagem: 'Você precisa de pelo menos uma propriedade.',
      textoBotao: 'Nova Propriedade',
      telaDestino: const CadastrarPropriedadeView(),
    );
  } 
  else if (talhoesVM.talhoes.isEmpty && propriedadesVM.idPropriedadeSelecionada != null) {
    return PendenciaCadastro(
      mensagem: 'Sua propriedade precisa de um talhão.',
      textoBotao: 'Novo Talhão',
      telaDestino: const CadastrarTalhaoView(),
    );
  } 
  else if (safraVM.safras.isEmpty && propriedadesVM.idPropriedadeSelecionada != null) {
    return PendenciaCadastro(
      mensagem: 'Último passo: Registre uma safra para começar.',
      textoBotao: 'Ir para Safras',
      telaDestino: const SafraViewPage(),
    );
  }

  return null; // Tudo completo!
}

// 👇 3. O WIDGET DO BANNER COM TEMPORIZADOR 👇
class BannerCadastroIncompleto extends StatefulWidget {
  const BannerCadastroIncompleto({super.key});

  @override
  State<BannerCadastroIncompleto> createState() => _BannerCadastroIncompletoState();
}

class _BannerCadastroIncompletoState extends State<BannerCadastroIncompleto> {
  bool _visivel = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inicia o contador de 4 segundos
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _visivel = false; // Faz o banner sumir
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Limpa o timer se o usuário sair da tela antes dos 4s
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendencia = verificarPendenciasDeCadastro(context);

    // Se não houver pendência, não mostra nada
    if (pendencia == null) return const SizedBox.shrink();

    // AnimatedSize faz o banner encolher suavemente quando _visivel virar false
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: _visivel
          ? Container(
              width: double.infinity,
              color: const Color(0xFFE8F5E9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFF67835C)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pendencia.mensagem,
                      style: const TextStyle(
                        color: Color(0xFF2E3D29),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF67835C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => pendencia.telaDestino),
                      );
                    },
                    child: Text(
                      pendencia.textoBotao, 
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  )
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
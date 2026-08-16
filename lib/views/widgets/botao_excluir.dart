import 'package:flutter/material.dart';

const _vermelhoErro = Color(0xFFD32F2F);

/// Ação de exclusão: o botão discreto e o diálogo de confirmação num só lugar.
///
/// Discreto de propósito, e alinhado à direita: excluir é irreversível e nunca é
/// o que o usuário veio fazer na tela. O peso visual fica com a ação primária —
/// salvar, encerrar, confirmar —, que continua sendo `CustomButton`.
///
/// O widget **não** mostra SnackBar nem faz `Navigator.pop`. O que vem depois da
/// exclusão diverge em cada tela (recarregar a listagem de talhões, a de
/// propriedades, devolver `true` para o detalhe anterior), então esse trecho fica
/// em [aoConfirmar], do lado de quem conhece a tela.
class BotaoExcluir extends StatelessWidget {
  /// Cabeçalho do diálogo: 'Excluir Talhão?'.
  final String titulo;

  /// Corpo do diálogo. Nomeie o registro e diga que não há volta — é a última
  /// tela antes da perda.
  final String mensagem;

  /// Chamado só depois do "Excluir" no diálogo.
  final Future<void> Function()? aoConfirmar;

  final String rotulo;

  /// Requisição em voo: sem isto um segundo toque dispara uma segunda chamada.
  final bool bloqueado;

  const BotaoExcluir({
    super.key,
    required this.titulo,
    required this.mensagem,
    required this.aoConfirmar,
    this.rotulo = 'Excluir',
    this.bloqueado = false,
  });

  Future<void> _confirmar(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              rotulo,
              style: const TextStyle(
                color: _vermelhoErro,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    await aoConfirmar?.call();
  }

  @override
  Widget build(BuildContext context) {
    final desabilitado = bloqueado || aoConfirmar == null;

    // Cinza durante a requisição: com a cor vermelha fixa e `onPressed` nulo, o
    // botão pareceria clicável e não responderia.
    final cor = desabilitado ? Colors.black38 : _vermelhoErro;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: desabilitado ? null : () => _confirmar(context),
          icon: Icon(Icons.delete_outline, color: cor),
          label: Text(rotulo, style: TextStyle(color: cor, fontSize: 16)),
        ),
      ],
    );
  }
}

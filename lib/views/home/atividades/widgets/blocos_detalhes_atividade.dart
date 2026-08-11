import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/eventos/eventos_agricolas/evento_agricola.dart';

const _verdePrimario = Color(0xFF67835C);
const _verdeSecundario = Color(0xFF8FA67E);

const _estiloRotulo = TextStyle(
  fontWeight: FontWeight.w600,
  color: Colors.black54,
  fontSize: 15,
);

/// Linha de atributo do cartão de detalhes.
///
/// Com [onEditar] ganha o lápis e vira ponto de toque; sem ele fica inerte.
/// É esse contraste que informa quais atributos têm endpoint de alteração —
/// marcar todos deixaria os não-editáveis parecendo quebrados.
///
/// O respiro vertical mora aqui dentro, e não como `SizedBox` entre as linhas,
/// para entrar na área de toque: rente ao texto o alvo fica com menos de 24px
/// de altura.
class LinhaInfoAtividade extends StatelessWidget {
  final String rotulo;
  final String valor;
  final VoidCallback? onEditar;

  const LinhaInfoAtividade({
    super.key,
    required this.rotulo,
    required this.valor,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final linha = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: _estiloRotulo),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
              textAlign: TextAlign.end,
            ),
          ),
          if (onEditar != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined, size: 16, color: _verdePrimario),
          ],
        ],
      ),
    );

    if (onEditar == null) return linha;

    return InkWell(
      onTap: onEditar,
      borderRadius: BorderRadius.circular(8),
      child: linha,
    );
  }
}

/// Bloco de atributo com conteúdo próprio — chips de responsáveis ou de
/// insumos.
///
/// Todo o bloco é área de toque, inclusive o estado vazio: é justamente quando
/// não há nada lançado que o usuário precisa achar a ação.
class SecaoEditavelAtividade extends StatelessWidget {
  final String titulo;
  final Widget conteudo;
  final VoidCallback? onEditar;

  const SecaoEditavelAtividade({
    super.key,
    required this.titulo,
    required this.conteudo,
    this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final bloco = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(titulo, style: _estiloRotulo),
              if (onEditar != null) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: _verdePrimario,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: conteudo),
        ],
      ),
    );

    if (onEditar == null) return bloco;

    return InkWell(
      onTap: onEditar,
      borderRadius: BorderRadius.circular(8),
      child: bloco,
    );
  }
}

/// Selo de "Em andamento" / "Finalizado" no cabeçalho do cartão.
class BadgeStatusAtividade extends StatelessWidget {
  final EventoAgricola atividade;

  const BadgeStatusAtividade({super.key, required this.atividade});

  @override
  Widget build(BuildContext context) {
    final cor = atividade.emAndamento ? _verdePrimario : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        atividade.statusFormatado,
        style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Conteúdo de uma [SecaoEditavelAtividade]: chips, ou uma frase quando vazio.
class ChipsAtividade extends StatelessWidget {
  final List<String> rotulos;
  final String textoVazio;

  const ChipsAtividade({
    super.key,
    required this.rotulos,
    required this.textoVazio,
  });

  @override
  Widget build(BuildContext context) {
    if (rotulos.isEmpty) {
      return Text(
        textoVazio,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: rotulos.map((rotulo) {
        return Chip(
          label: Text(
            rotulo,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: _verdeSecundario,
        );
      }).toList(),
    );
  }
}

/// Aviso de que a atividade está fechada para edição.
class AvisoAtividadeFinalizada extends StatelessWidget {
  final String mensagem;

  const AvisoAtividadeFinalizada({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

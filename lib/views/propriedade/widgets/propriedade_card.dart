import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/model/propriedade.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/cartao_entidade.dart';

class CardPropriedadeWidget extends StatelessWidget {
  final Propriedade propriedade;
  final VoidCallback? onTap;

  final IconData iconeAcao;

  const CardPropriedadeWidget({
    super.key,
    required this.propriedade,
    this.onTap,
    this.iconeAcao = Icons.arrow_forward_ios,
  });

  @override
  Widget build(BuildContext context) {
    final endereco = propriedade.endereco;

    return CartaoEntidade(
      icone: Icons.landscape,
      titulo: propriedade.nome,
      onTap: onTap,
      margem: EdgeInsets.zero,
      acao: onTap == null
          ? null
          : Icon(iconeAcao, size: 16, color: Colors.black26),
      corpo: [
        LinhaCartao(
          icone: Icons.square_foot,
          titulo: 'Tamanho',
          valor: propriedade.tamanho.formatado,
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.location_on_outlined,
          titulo: 'Localização',
          valor: '${endereco.cidade} - ${endereco.uf.name}',
        ),
        const SizedBox(height: 12),
        LinhaCartao(
          icone: Icons.map_outlined,
          titulo: 'Endereço',
          valor:
              '${endereco.logradouro}, ${endereco.bairro}\n'
              'CEP: ${endereco.cep.formatado}',
        ),
      ],
    );
  }
}

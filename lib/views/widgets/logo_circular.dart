import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

const _caminhoDaLogoComNome = 'assets/images/Logo.svg';
const _caminhoDaLogoSemNome = 'assets/images/logo_sem_nome.svg';

class LogoSysgrano extends StatelessWidget {
  final double? altura;
  final double? largura;
  final bool comNome;

  const LogoSysgrano({
    super.key,
    this.altura,
    this.largura,
    this.comNome = false,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      comNome ? _caminhoDaLogoComNome : _caminhoDaLogoSemNome,
      height: altura,
      width: largura,
      fit: BoxFit.contain,
      semanticsLabel: 'Sysgrano',
    );
  }
}

class LogoCircular extends StatelessWidget {
  final double size;

  const LogoCircular({super.key, this.size = 130.0});

  static const _fracaoDaMargem = 0.095;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * _fracaoDaMargem),
      decoration: BoxDecoration(
        color: AppCores.superficie,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppCores.textoPrimario.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const LogoSysgrano(),
    );
  }
}

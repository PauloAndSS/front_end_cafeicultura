import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';

class TelaDeAbertura extends StatelessWidget {
  const TelaDeAbertura({super.key});

  static const _ladoDaLogo = 240.0;
  static const _respiro = 32.0;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppCores.superficie,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: _ladoDaLogo,
              child: LogoSysgrano(comNome: true),
            ),
            SizedBox(height: _respiro),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

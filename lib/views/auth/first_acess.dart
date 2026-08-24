import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/logo_circular.dart';
import 'package:frond_end_cafeicultura_mobile/views/widgets/button_widget.dart';
import 'entrar_view.dart';
import '../proprietario/cadastrar_dados_basicos_view.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

class FirstAcess extends StatelessWidget {
  const FirstAcess({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = screenHeight * 0.45;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: Image.asset(
              'assets/images/banner_cafe.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.60,
            child: Container(
              decoration: const BoxDecoration(
                color: AppCores.verdeAuth,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  CustomButton(
                    text: "Já tenho uma conta",
                    onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => const EntrarView()),
                    )
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    text: "Criar uma conta",
                    onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => const CadastrarUsuarioView())),
                    backgroundColor: Colors.white,
                    foregroundColor: AppCores.verdePrimario
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: bannerHeight - 65,
            left: (screenWidth / 2) - 65,
            child: const LogoCircular(),
          ),
        ],
      ),
    );
  }
}

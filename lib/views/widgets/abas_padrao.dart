import 'package:flutter/material.dart';
import 'package:frond_end_cafeicultura_mobile/views/theme/app_cores.dart';

TabBar abasPadrao({
  required List<Tab> abas,
  TabController? controller,
  bool rolavel = false,
}) {
  return TabBar(
    controller: controller,
    isScrollable: rolavel,
    tabAlignment: rolavel ? TabAlignment.start : null,
    labelColor: AppCores.verdePrimario,
    unselectedLabelColor: Colors.grey,
    indicatorColor: AppCores.verdePrimario,
    indicatorWeight: 3.0,
    dividerColor: Colors.transparent,
    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    tabs: abas,
  );
}

class BarraDeAbas extends StatelessWidget implements PreferredSizeWidget {
  final List<Tab> abas;
  final TabController? controller;
  final bool rolavel;

  const BarraDeAbas({
    super.key,
    required this.abas,
    this.controller,
    this.rolavel = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: abasPadrao(abas: abas, controller: controller, rolavel: rolavel),
    );
  }
}

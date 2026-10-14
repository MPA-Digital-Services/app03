import 'package:flutter/material.dart';

import '../../procedures/presentation/procedures_screen.dart';
import '../../views/presentation/views_screen.dart';

/// Pestaña "Consultas": navegador de vistas y de procedimientos almacenados.
class QueriesScreen extends StatelessWidget {
  const QueriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Consultas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.grid_on_outlined), text: 'Vistas'),
              Tab(icon: Icon(Icons.play_circle_outline), text: 'Procedimientos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ViewsScreen(),
            ProceduresScreen(),
          ],
        ),
      ),
    );
  }
}

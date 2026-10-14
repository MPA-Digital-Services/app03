import 'package:flutter/material.dart';

import '../../../core/crud/entity_list_screen.dart';
import '../../../core/crud/entity_spec.dart';
import '../entity_descriptors.dart';

/// Catálogo de entidades gestionables; abre el listado CRUD de cada una.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entities = NorthwindEntities.all;
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text(
              'Selecciona una entidad para consultar, crear, editar o eliminar registros.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          for (final entity in entities)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    entity.icon,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(entity.title),
                subtitle: Text('${entity.listFields.length} columnas · ${entity.route}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EntityListScreen(spec: entity),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Fila de catálogo usada internamente si se requiere una lista compacta.
class EntityTile extends StatelessWidget {
  const EntityTile({super.key, required this.entity});

  final EntitySpec entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(entity.icon),
      title: Text(entity.title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EntityListScreen(spec: entity)),
      ),
    );
  }
}

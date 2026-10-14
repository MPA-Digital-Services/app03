import 'package:flutter/material.dart';

/// Entrada de datos para [SimpleBarChart].
class BarDatum {
  const BarDatum(this.label, this.value);
  final String label;
  final double value;
}

/// Gráfico de barras vertical simple, sin dependencias externas.
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.data,
    this.height = 160,
    this.valueFormatter,
    this.barColor,
  });

  final List<BarDatum> data;
  final double height;
  final String Function(double value)? valueFormatter;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sin datos para graficar.')),
      );
    }

    final maxValue = data
        .map((d) => d.value)
        .fold<double>(0, (prev, v) => v > prev ? v : prev);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final scheme = Theme.of(context).colorScheme;
    final color = barColor ?? scheme.primary;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final datum in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      valueFormatter?.call(datum.value) ??
                          datum.value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final fraction = datum.value / safeMax;
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: constraints.maxHeight * fraction,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      datum.label,
                      style: Theme.of(context).textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Fila de barra horizontal (etiqueta + barra + valor), útil para rankings.
class RankBar extends StatelessWidget {
  const RankBar({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    this.valueLabel,
  });

  final String label;
  final double value;
  final double fraction;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                valueLabel ?? value.toStringAsFixed(0),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

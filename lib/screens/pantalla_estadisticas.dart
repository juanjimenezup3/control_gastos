import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gasto.dart';

class PantallaEstadisticas extends StatelessWidget {
  const PantallaEstadisticas({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Gasto>('gastos');
    
    // Calculamos totales
    double pagado = 0;
    double pendiente = 0;

    for (var gasto in box.values) {
      if (gasto.estaPagado) {
        pagado += gasto.monto;
      } else {
        pendiente += gasto.monto;
      }
    }

    double total = pagado + pendiente;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de Gastos')),
      body: total == 0 
        ? const Center(child: Text("No hay datos para analizar"))
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text("Distribución de Gastos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: pagado,
                          title: 'Pagado',
                          color: Colors.green,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        PieChartSectionData(
                          value: pendiente,
                          title: 'Pendiente',
                          color: Colors.orange,
                          radius: 60,
                          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildFilaDato("Total Pagado", pagado, Colors.green),
                _buildFilaDato("Total Pendiente", pendiente, Colors.orange),
                const Divider(),
                _buildFilaDato("Gasto Total", total, Colors.blueGrey),
              ],
            ),
          ),
    );
  }

  Widget _buildFilaDato(String label, double valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color, radius: 6),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
          Text('\$${valor.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
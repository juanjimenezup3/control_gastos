import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- 1. IMPORTANTE: Importamos esto

void main() {
  runApp(MiAppDeGastos());
}

class MiAppDeGastos extends StatelessWidget {
  const MiAppDeGastos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PantallaInicio(),
    );
  }
}

class Gasto {
  String nombre;
  double monto;
  bool estaPagado;

  Gasto({required this.nombre, required this.monto, this.estaPagado = false});
}

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  double dineroTotal = 0;
  List<Gasto> gastos = [];

  // --- 2. CONFIGURACIÓN DEL FORMATO ---
  // Esto crea un formateador que pone puntos en miles y signo de pesos.
  // decimalDigits: 0 hace que se vea "1.000.000" (sin centavos)
  // Si quieres centavos, cambia a decimalDigits: 2
  final formater = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  void _mostrarDialogoAgregarDinero() {
    TextEditingController controlador = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Ingreso'),
          content: TextField(
            controller: controlador,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cantidad',
              prefixText: '\$',
              hintText: 'Ej: 1000000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Quitamos puntos o comas antes de guardar para que no de error
                String limpio = controlador.text.replaceAll('.', '').replaceAll(',', '');
                double cantidad = double.tryParse(limpio) ?? 0;
                
                if (cantidad > 0) {
                  setState(() {
                    dineroTotal += cantidad;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _editarDineroTotal() {
    // Al editar, mostramos el número limpio sin puntos para que sea fácil borrar
    TextEditingController controlador = TextEditingController(text: dineroTotal.toInt().toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Corregir Saldo Actual'),
          content: TextField(
            controller: controlador,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Nuevo Saldo Real',
              prefixText: '\$',
              hintText: 'Ej: 50000',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                String limpio = controlador.text.replaceAll('.', '').replaceAll(',', '');
                double nuevoValor = double.tryParse(limpio) ?? dineroTotal;

                setState(() {
                  dineroTotal = nuevoValor;
                });
                Navigator.pop(context);
              },
              child: Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoRestarDinero() {
    TextEditingController controladorNombre = TextEditingController();
    TextEditingController controladorMonto = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controladorNombre,
                decoration: InputDecoration(
                  labelText: 'Nombre del gasto',
                  hintText: 'Ej: Arriendo',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controladorMonto,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                String nombre = controladorNombre.text.trim();
                String limpio = controladorMonto.text.replaceAll('.', '').replaceAll(',', '');
                double monto = double.tryParse(limpio) ?? 0;

                if (nombre.isNotEmpty && monto > 0) {
                  setState(() {
                    gastos.add(Gasto(nombre: nombre, monto: monto));
                    dineroTotal -= monto;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Dinero'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _editarDineroTotal,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: dineroTotal >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Dinero Disponible', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 5),
                        Icon(Icons.edit, size: 16, color: Colors.grey),
                      ],
                    ),
                    // --- 3. AQUÍ USAMOS EL FORMATEADOR ---
                    Text(
                      formater.format(dineroTotal), // <--- ¡Mira esto!
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: dineroTotal >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _mostrarDialogoAgregarDinero,
                  icon: Icon(Icons.add),
                  label: Text('Ingreso'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: _mostrarDialogoRestarDinero,
                  icon: Icon(Icons.remove),
                  label: Text('Gasto'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Historial de Gastos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: gastos.isEmpty
                  ? Center(child: Text("No hay gastos registrados"))
                  : ListView.builder(
                      itemCount: gastos.length,
                      itemBuilder: (context, index) {
                        final gasto = gastos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(Icons.money_off, color: Colors.red),
                            title: Text(gasto.nombre),
                            subtitle: Text(gasto.estaPagado ? 'Pagado' : 'Pendiente'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // --- 4. TAMBIÉN FORMATEAMOS LOS GASTOS ---
                                Text(
                                  '-${formater.format(gasto.monto)}', // <--- ¡Y aquí!
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      dineroTotal += gasto.monto;
                                      gastos.removeAt(index);
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
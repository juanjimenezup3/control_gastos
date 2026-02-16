import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibration/vibration.dart';
import '../services/notification_service.dart';
import '../models/gasto.dart';
import 'pantalla_estadisticas.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> with SingleTickerProviderStateMixin {
  double dineroTotal = 0;
  late Box<Gasto> _gastosBox;
  late TabController _tabController;
  final formater = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _gastosBox = Hive.box<Gasto>('gastos');
    final configBox = Hive.box('config');
    dineroTotal = (configBox.get('dineroTotal') ?? 0).toDouble();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _actualizarSaldo(double nuevoSaldo) {
    setState(() {
      dineroTotal = nuevoSaldo;
      Hive.box('config').put('dineroTotal', dineroTotal);
    });
  }

  void _mostrarDialogoAgregarDinero() {
    TextEditingController controlador = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Ingreso'),
        content: TextField(
          controller: controlador,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Cantidad', prefixText: '\$', hintText: 'Ej: 50000'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              double cantidad = double.tryParse(controlador.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
              if (cantidad > 0) {
                _actualizarSaldo(dineroTotal + cantidad);
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoRestarDinero() {
    TextEditingController controladorNombre = TextEditingController();
    TextEditingController controladorMonto = TextEditingController();
    DateTime? fechaVencimiento;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Gasto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controladorNombre, decoration: const InputDecoration(labelText: '¿En qué gastaste?')),
              TextField(
                controller: controladorMonto,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$'),
              ),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (context, setStepState) => TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(fechaVencimiento == null
                      ? 'Fecha límite (Opcional)'
                      : 'Vence: ${DateFormat('dd/MM/yyyy').format(fechaVencimiento!)}'),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setStepState(() => fechaVencimiento = picked);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ElevatedButton(
            onPressed: () {
              String nombre = controladorNombre.text.trim();
              double monto = double.tryParse(controladorMonto.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
              if (nombre.isNotEmpty && monto > 0) {
                final nuevoGasto = Gasto(nombre: nombre, monto: monto, fechaVencimiento: fechaVencimiento);
                _gastosBox.add(nuevoGasto);
                if (fechaVencimiento != null) {
                  NotificationService.programarAviso(
                    id: nuevoGasto.hashCode,
                    titulo: '¡Vencimiento de Pago!',
                    cuerpo: 'Hoy vence: $nombre por ${formater.format(monto)}',
                    fechaVencimiento: fechaVencimiento!,
                  );
                }
                _actualizarSaldo(dineroTotal - monto);
                Navigator.pop(context);
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditar(int realIndex, Gasto gasto) {
    TextEditingController controladorNombre = TextEditingController(text: gasto.nombre);
    TextEditingController controladorMonto = TextEditingController(text: gasto.monto.toInt().toString());
    DateTime? fechaVencimiento = gasto.fechaVencimiento;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Gasto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controladorNombre, decoration: const InputDecoration(labelText: '¿En qué gastaste?')),
              TextField(
                controller: controladorMonto,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$'),
              ),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (context, setStepState) => TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(fechaVencimiento == null
                      ? 'Fecha límite (Opcional)'
                      : 'Vence: ${DateFormat('dd/MM/yyyy').format(fechaVencimiento!)}'),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: fechaVencimiento ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setStepState(() => fechaVencimiento = picked);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              String nombre = controladorNombre.text.trim();
              double nuevoMonto = double.tryParse(controladorMonto.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
              if (nombre.isNotEmpty && nuevoMonto > 0) {
                double diferencia = nuevoMonto - gasto.monto;
                gasto.nombre = nombre;
                gasto.monto = nuevoMonto;
                gasto.fechaVencimiento = fechaVencimiento;
                gasto.save();
                _actualizarSaldo(dineroTotal - diferencia);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminacion(int index, Gasto gasto) async {
    Vibration.vibrate(duration: 200);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Text('Se devolverán ${formater.format(gasto.monto)} a tu saldo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('NO')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              NotificationService.cancelarNotificacion(gasto.hashCode);
              _actualizarSaldo(dineroTotal + gasto.monto);
              _gastosBox.deleteAt(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Eliminado correctamente')),
              );
            },
            child: const Text('SÍ, ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Control Financiero', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: "Ver Estadísticas",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PantallaEstadisticas()),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'GASTOS PENDIENTES'),
            Tab(text: 'TAREAS PENDIENTES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPestanaGastos(),
          _buildPestanaTareas(),
        ],
      ),
    );
  }

  Widget _buildTarjetaSaldo() {
    bool esPositivo = dineroTotal >= 0;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: esPositivo
              ? [Colors.green.shade400, Colors.green.shade700]
              : [Colors.red.shade400, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          const Text('Saldo Disponible', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              formater.format(dineroTotal),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilaBotones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _mostrarDialogoAgregarDinero,
          icon: const Icon(Icons.add),
          label: const Text("Ingreso"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        ),
        ElevatedButton.icon(
          onPressed: _mostrarDialogoRestarDinero,
          icon: const Icon(Icons.remove),
          label: const Text("Gasto"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        ),
      ],
    );
  }

  Widget _buildListaMovimientos() {
    return ValueListenableBuilder(
      valueListenable: _gastosBox.listenable(),
      builder: (context, Box<Gasto> box, _) {
        if (box.isEmpty) return const Center(child: Text("No hay registros aún."));

        final lista = box.values.toList().reversed.toList();

        return ListView.builder(
          itemCount: lista.length,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            final gasto = lista[index];
            final realIndex = box.length - 1 - index;

            bool estaVencido = gasto.fechaVencimiento != null &&
                gasto.fechaVencimiento!.isBefore(DateTime.now()) &&
                !gasto.estaPagado;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: ListTile(
                onTap: () => _mostrarDialogoEditar(realIndex, gasto),
                onLongPress: () => _confirmarEliminacion(realIndex, gasto),
                leading: Checkbox(
                  activeColor: Colors.green,
                  value: gasto.estaPagado,
                  onChanged: (v) {
                    setState(() {
                      gasto.estaPagado = v!;
                      if (gasto.estaPagado) {
                        NotificationService.cancelarNotificacion(gasto.hashCode);
                      }
                    });
                    gasto.save();
                  },
                ),
                title: Text(
                  gasto.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: gasto.estaPagado ? TextDecoration.lineThrough : null,
                    color: gasto.estaPagado ? Colors.grey : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(gasto.fecha)),
                    if (gasto.fechaVencimiento != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Vence: ${DateFormat('dd/MM/yyyy').format(gasto.fechaVencimiento!)}',
                          style: TextStyle(
                            color: estaVencido ? Colors.red : Colors.orange.shade800,
                            fontWeight: estaVencido ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    const Text(
                      'Mantén presionado para eliminar',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "-${formater.format(gasto.monto)}",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    if (estaVencido)
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPestanaGastos() {
    return Column(
      children: [
        _buildTarjetaSaldo(),
        _buildFilaBotones(),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Historial de Gastos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(child: _buildListaMovimientos()),
      ],
    );
  }

  Widget _buildPestanaTareas() {
    return const Center(
      child: Text("Tareas Pendientes - Próximamente"),
    );
  }
}
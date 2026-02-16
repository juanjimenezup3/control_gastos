import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibration/vibration.dart';
import '../services/notification_service.dart';
import '../models/gasto.dart';
import '../models/tarea.dart';
import 'pantalla_estadisticas.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> with SingleTickerProviderStateMixin {
  double dineroTotal = 0;
  late Box<Gasto> _gastosBox;
  late Box<Tarea> _tareasBox;
  late TabController _tabController;
  final formater = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
  final fechaHoraFormat = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    _gastosBox = Hive.box<Gasto>('gastos');
    _tareasBox = Hive.box<Tarea>('tareas');
    final configBox = Hive.box('config');
    dineroTotal = (configBox.get('dineroTotal') ?? 0).toDouble();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- SELECCIONAR FECHA Y HORA ---
  Future<DateTime?> _seleccionarFechaYHora(BuildContext context, DateTime? fechaInicial) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicial ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fecha == null) return null;

    if (!context.mounted) return fecha;
    
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(fechaInicial ?? DateTime.now()),
    );

    if (hora == null) return fecha;

    return DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );
  }

  // --- LOGICA DINERO ---
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
                  icon: const Icon(Icons.access_time_filled),
                  label: Text(fechaVencimiento == null
                      ? 'Programar Fecha y Hora'
                      : 'Vence: ${fechaHoraFormat.format(fechaVencimiento!)}'),
                  style: TextButton.styleFrom(
                    foregroundColor: fechaVencimiento != null ? Colors.blueAccent : Colors.grey,
                  ),
                  onPressed: () async {
                    DateTime? picked = await _seleccionarFechaYHora(context, null);
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

  // --- LOGICA TAREAS ---

  void _mostrarDialogoAgregarTarea() {
    TextEditingController controladorNombre = TextEditingController();
    TextEditingController controladorDesc = TextEditingController();
    DateTime? fechaLimite;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Tarea'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controladorNombre, 
                decoration: const InputDecoration(labelText: 'Nombre de la tarea', hintText: 'Ej: Pagar internet'),
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: controladorDesc,
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (context, setStepState) => TextButton.icon(
                  icon: const Icon(Icons.access_time_filled),
                  label: Text(fechaLimite == null
                      ? 'Programar Fecha y Hora'
                      : 'Para el: ${fechaHoraFormat.format(fechaLimite!)}'),
                   style: TextButton.styleFrom(
                    foregroundColor: fechaLimite != null ? Colors.blueAccent : Colors.grey,
                  ),
                  onPressed: () async {
                    DateTime? picked = await _seleccionarFechaYHora(context, null);
                    if (picked != null) setStepState(() => fechaLimite = picked);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            onPressed: () {
              String nombre = controladorNombre.text.trim();
              String desc = controladorDesc.text.trim();

              if (nombre.isNotEmpty) {
                final nuevaTarea = Tarea(
                  nombre: nombre, 
                  descripcion: desc,
                  fechaLimite: fechaLimite,
                  estaCompletada: false
                );
                
                _tareasBox.add(nuevaTarea);

                if (fechaLimite != null) {
                  NotificationService.programarAviso(
                    id: nuevaTarea.hashCode,
                    titulo: '¡Tarea Pendiente!',
                    cuerpo: 'Recuerda: $nombre',
                    fechaVencimiento: fechaLimite!,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar Tarea'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarTarea(Tarea tarea) {
    TextEditingController controladorNombre = TextEditingController(text: tarea.nombre);
    TextEditingController controladorDesc = TextEditingController(text: tarea.descripcion);
    DateTime? fechaLimite = tarea.fechaLimite;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controladorNombre, 
                decoration: const InputDecoration(labelText: 'Nombre de la tarea'),
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: controladorDesc,
                decoration: const InputDecoration(labelText: 'Descripción'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (context, setStepState) => TextButton.icon(
                  icon: const Icon(Icons.access_time_filled),
                  label: Text(fechaLimite == null
                      ? 'Programar Fecha y Hora'
                      : 'Para el: ${fechaHoraFormat.format(fechaLimite!)}'),
                  style: TextButton.styleFrom(
                    foregroundColor: fechaLimite != null ? Colors.blueAccent : Colors.grey,
                  ),
                  onPressed: () async {
                    DateTime? picked = await _seleccionarFechaYHora(context, fechaLimite);
                    if (picked != null) setStepState(() => fechaLimite = picked);
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
              String desc = controladorDesc.text.trim();

              if (nombre.isNotEmpty) {
                // Cancelamos la notificación anterior si existía
                NotificationService.cancelarNotificacion(tarea.hashCode);

                tarea.nombre = nombre;
                tarea.descripcion = desc;
                tarea.fechaLimite = fechaLimite;
                tarea.save();

                // Programamos la nueva si hay fecha
                if (fechaLimite != null && !tarea.estaCompletada) {
                  NotificationService.programarAviso(
                    id: tarea.hashCode,
                    titulo: '¡Tarea Pendiente!',
                    cuerpo: 'Recuerda: $nombre',
                    fechaVencimiento: fechaLimite!,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  // --- EDITAR GASTO ---
  void _mostrarDialogoEditarGasto(int realIndex, Gasto gasto) {
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
              TextField(controller: controladorNombre, decoration: const InputDecoration(labelText: 'Concepto')),
              TextField(controller: controladorMonto, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto')),
              const SizedBox(height: 15),
              StatefulBuilder(
                builder: (context, setStepState) => TextButton.icon(
                  icon: const Icon(Icons.access_time_filled),
                  label: Text(fechaVencimiento == null
                      ? 'Sin fecha límite'
                      : 'Vence: ${fechaHoraFormat.format(fechaVencimiento!)}'),
                  onPressed: () async {
                     DateTime? picked = await _seleccionarFechaYHora(context, fechaVencimiento);
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
                     double nuevoMonto = double.tryParse(controladorMonto.text) ?? 0;
                     if(nombre.isNotEmpty){
                        double diferencia = nuevoMonto - gasto.monto;
                        
                        NotificationService.cancelarNotificacion(gasto.hashCode);

                        gasto.nombre = nombre;
                        gasto.monto = nuevoMonto;
                        gasto.fechaVencimiento = fechaVencimiento;
                        gasto.save();
                        _actualizarSaldo(dineroTotal - diferencia);
                        
                        if(fechaVencimiento != null && !gasto.estaPagado) {
                           NotificationService.programarAviso(
                              id: gasto.hashCode, 
                              titulo: '¡Vencimiento Actualizado!', 
                              cuerpo: 'Vence: $nombre', 
                              fechaVencimiento: fechaVencimiento!
                           );
                        }
                        Navigator.pop(context);
                     }
                },
                child: const Text('Guardar'))
        ]
      ),
    );
  }
  
  void _confirmarEliminacionGenerica({
      required String titulo, 
      required String contenido, 
      required VoidCallback onConfirm
  }) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado correctamente')));
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
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
            Tab(text: 'GASTOS'),
            Tab(text: 'TAREAS'),
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

  // --- WIDGETS GASTOS ---
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

  Widget _buildFilaBotonesGastos() {
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

  Widget _buildListaGastos() {
    return ValueListenableBuilder(
      valueListenable: _gastosBox.listenable(),
      builder: (context, Box<Gasto> box, _) {
        if (box.isEmpty) return const Center(child: Text("No hay gastos registrados."));

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
                onTap: () => _mostrarDialogoEditarGasto(realIndex, gasto),
                onLongPress: () => _confirmarEliminacionGenerica(
                    titulo: "¿Eliminar Gasto?", 
                    contenido: "Se devolverán ${formater.format(gasto.monto)} al saldo.",
                    onConfirm: () {
                        NotificationService.cancelarNotificacion(gasto.hashCode);
                        _actualizarSaldo(dineroTotal + gasto.monto);
                        _gastosBox.deleteAt(realIndex);
                    }
                ),
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
                subtitle: gasto.fechaVencimiento != null 
                    ? Text('Vence: ${fechaHoraFormat.format(gasto.fechaVencimiento!)}',
                        style: TextStyle(color: estaVencido ? Colors.red : Colors.grey))
                    : null,
                trailing: Text(
                  "-${formater.format(gasto.monto)}",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- WIDGETS TAREAS ---
  Widget _buildPestanaTareas() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_task),
              label: const Text("AGREGAR NUEVA TAREA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _mostrarDialogoAgregarTarea,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Lista de Tareas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(child: _buildListaTareas()),
      ],
    );
  }

  Widget _buildListaTareas() {
    return ValueListenableBuilder(
      valueListenable: _tareasBox.listenable(),
      builder: (context, Box<Tarea> box, _) {
        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("¡Todo al día!", style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }

        final lista = box.values.toList().reversed.toList();

        return ListView.builder(
          itemCount: lista.length,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            final tarea = lista[index];
            final realIndex = box.length - 1 - index;
            
            bool estaVencida = tarea.fechaLimite != null &&
                tarea.fechaLimite!.isBefore(DateTime.now()) &&
                !tarea.estaCompletada;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: ListTile(
                onTap: () => _mostrarDialogoEditarTarea(tarea), // <--- AQUI ESTABA LO QUE FALTABA
                onLongPress: () => _confirmarEliminacionGenerica(
                    titulo: "¿Eliminar Tarea?",
                    contenido: "Esta acción no se puede deshacer.",
                    onConfirm: () {
                        NotificationService.cancelarNotificacion(tarea.hashCode);
                        _tareasBox.deleteAt(realIndex);
                    }
                ),
                leading: Checkbox(
                  activeColor: Colors.blueAccent,
                  value: tarea.estaCompletada,
                  onChanged: (v) {
                    setState(() {
                      tarea.estaCompletada = v!;
                      if (tarea.estaCompletada) {
                        NotificationService.cancelarNotificacion(tarea.hashCode);
                      }
                    });
                    tarea.save();
                  },
                ),
                title: Text(
                  tarea.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: tarea.estaCompletada ? TextDecoration.lineThrough : null,
                    color: tarea.estaCompletada ? Colors.grey : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tarea.descripcion.isNotEmpty)
                      Text(tarea.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (tarea.fechaLimite != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: estaVencida ? Colors.red : Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              fechaHoraFormat.format(tarea.fechaLimite!),
                              style: TextStyle(
                                fontSize: 12,
                                color: estaVencida ? Colors.red : Colors.grey[600],
                                fontWeight: estaVencida ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _confirmarEliminacionGenerica(
                        titulo: "¿Eliminar Tarea?",
                        contenido: "Se borrará permanentemente.",
                        onConfirm: () {
                             NotificationService.cancelarNotificacion(tarea.hashCode);
                            _tareasBox.deleteAt(realIndex);
                        }
                    ),
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
        _buildFilaBotonesGastos(),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Historial de Gastos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(child: _buildListaGastos()),
      ],
    );
  }
}
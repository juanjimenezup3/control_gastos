import 'package:flutter/material.dart';
import 'screens/pantalla_inicio.dart';
import 'models/gasto.dart';
import 'package:hive_flutter/hive_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(GastoAdapter());
  await Hive.openBox<Gasto>('gastos');
  await Hive.openBox('config');
  runApp(MiAppDeGastos());
}

class  MiAppDeGastos extends StatelessWidget {
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



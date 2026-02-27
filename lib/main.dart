import 'package:control_gastos/services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/gasto.dart';
import 'models/tarea.dart';
import 'screens/pantalla_inicio.dart';
import 'services/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Google AdMob
  await AdService.init();
  
  await Hive.initFlutter();
  
  // Registramos los adaptadores
  Hive.registerAdapter(GastoAdapter());
  Hive.registerAdapter(TareaAdapter());
  
  // Abrimos las cajas (base de datos)
  await Hive.openBox('config');
  await Hive.openBox<Gasto>('gastos');
  await Hive.openBox<Tarea>('tareas');

  await NotificationService.init(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Priority Control Gastos', // Nombre actualizado
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          centerTitle: true, // Centramos el título por estética
        ),
      ),
      home: const PantallaInicio(),
    );
  }
}
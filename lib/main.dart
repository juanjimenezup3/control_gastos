import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/gasto.dart';
import 'models/tarea.dart'; // <--- 1. NUEVO: Importamos el modelo
import 'screens/pantalla_inicio.dart';
import 'services/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Registramos los adaptadores
  Hive.registerAdapter(GastoAdapter());
  Hive.registerAdapter(TareaAdapter()); // <--- 2. NUEVO: Registramos el adaptador de Tareas
  
  // Abrimos las cajas (base de datos)
  await Hive.openBox('config');
  await Hive.openBox<Gasto>('gastos');
  await Hive.openBox<Tarea>('tareas'); // <--- 3. NUEVO: Abrimos la caja de tareas

  await NotificationService.init(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control de Gastos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
      home: const PantallaInicio(),
    );
  }
}
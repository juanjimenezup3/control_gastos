import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/gasto.dart';
import 'screens/pantalla_inicio.dart';
// IMPORTANTE: Asegúrate de que el nombre del archivo coincida (con 's' o sin 's')
import 'services/notification_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(GastoAdapter());
  
  await Hive.openBox('config');
  await Hive.openBox<Gasto>('gastos');

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
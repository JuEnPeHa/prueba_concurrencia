import 'package:flutter/material.dart';
import 'package:prueba_concurrencia/ejemplos/ejemplo_async.dart';
import 'package:prueba_concurrencia/ejemplos/ejemplo_isolate_compute.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DemoConcurrencia(),
    );
  }
}

class DemoConcurrencia extends StatelessWidget {
  const DemoConcurrencia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Concurrencia')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ObtenerDatos()),
                );
              },
              child: const Text('Ejemplo Async'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TareaPesada()),
                );
              },
              child: const Text('Ejemplo Compute Isolate'),
            ),
          ],
        ),
      ),
    );
  }
}

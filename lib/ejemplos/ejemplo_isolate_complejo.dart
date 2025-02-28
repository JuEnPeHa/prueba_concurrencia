import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:prueba_concurrencia/ejemplos/ejemplo_isolate_compute.dart';

class IsolateComplejo extends StatefulWidget {
  const IsolateComplejo({super.key});

  @override
  State<IsolateComplejo> createState() => _IsolateComplejoState();
}

class _IsolateComplejoState extends State<IsolateComplejo> {
  List<String> updates = [];
  bool isComputing = false;
  Isolate? _isolate;
  ReceivePort? _receivePort;

  // Parámetros de la tarea pesada
  final int maxIterations = max;
  final int updateInterval = 1250;

  @override
  void dispose() {
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }

  void startComputation() async {
    setState(() {
      isComputing = true;
      updates = [];
    });

    final startTime = DateTime.now();

    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);

    _receivePort = ReceivePort();
    // Se crea el isolate pasando el SendPort, maxIterations y updateInterval
    _isolate = await Isolate.spawn(fibonacciIsolateEntry, [
      _receivePort!.sendPort,
      maxIterations,
      updateInterval,
    ]);

    // Escuchar los mensajes que vienen del isolate
    _receivePort!.listen((message) {
      if (message is String) {
        if (message == "COMPLETED") {
          setState(() {
            isComputing = false;
          });
          _receivePort!.close();

          final endTime = DateTime.now();
          final duration = endTime.difference(startTime);
          setState(() {
            updates.add("Tiempo transcurrido: ${duration}");
          });
        } else {
          setState(() {
            updates.add(message);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Isolate Complejo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isComputing ? null : startComputation,
              child: Text(isComputing ? "Procesando..." : "Iniciar Cómputo"),
            ),
            const SizedBox(height: 16),
            const Text("Actualizaciones:"),
            Expanded(
              child: ListView.builder(
                itemCount: updates.length,
                itemBuilder: (context, index) {
                  return Text(updates[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Función que se ejecuta en el isolate
Future<void> fibonacciIsolateEntry(List<dynamic> args) async {
  final SendPort sendPort = args[0];
  final int max = args[1];
  final int updateInterval = args[2];

  int n1 = 0, n2 = 1, n3;
  String partialResult = "";

  // Se calcula la serie Fibonacci
  for (int i = 1; i <= max; i++) {
    n3 = n1 + n2;
    n1 = n2;
    n2 = n3;
    partialResult += "$n3 ";

    // Cada updateInterval iteraciones, se envía una actualización
    if (i % updateInterval == 0) {
      sendPort.send("Iteración $i:\n$n1,$n2,$n3");
      // Reiniciamos el acumulador para la siguiente actualización
      partialResult = "";
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  // Si quedó alguna parte sin enviar, la mandamos
  if (partialResult.isNotEmpty) {
    sendPort.send("Final:\n$partialResult");
  }

  // Se envía un mensaje de finalización
  sendPort.send("COMPLETED");
}

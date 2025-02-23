// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prueba_concurrencia/animated_container.dart';

String tareaPesada(int max) {
  int n1 = 0, n2 = 1, n3;
  String result = "";
  for (int i = 1; i <= max; i++) {
    n3 = n1 + n2;
    n1 = n2;
    n2 = n3;
    result += "$n3 ";
  }
  return result;
}

const int max = 17500;

class TareaPesada extends StatefulWidget {
  const TareaPesada({super.key});

  @override
  State<TareaPesada> createState() => _TareaPesadaState();
}

class _TareaPesadaState extends State<TareaPesada> {
  bool isComputing = false;

  void llamarTareaPesadaDirectamente() {
    setState(() {
      isComputing = true;
    });
    final DateTime inicio = DateTime.now();
    String resultado = tareaPesada(max);
    final DateTime fin = DateTime.now();
    print(
      "Tiempo de ejecución: ${fin.difference(inicio)} resultado: ${resultado}",
    );
    setState(() {
      isComputing = false;
    });
  }

  void llamarTareaPesadaCompute() async {
    setState(() {
      isComputing = true;
    });
    final DateTime inicio = DateTime.now();
    String resultado = await compute(tareaPesada, max);
    final DateTime fin = DateTime.now();
    print(
      "Tiempo de ejecución (compute): ${fin.difference(inicio)} resultado: $resultado",
    );
    setState(() {
      isComputing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tarea Pesada")),
      body: Center(
        child: Column(
          children: [
            Expanded(child: AnimatedContainerM(child: Container())),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    isComputing
                        ? [CircularProgressIndicator()]
                        : [
                          ElevatedButton(
                            onPressed:
                                isComputing
                                    ? null
                                    : llamarTareaPesadaDirectamente,
                            child: const Text("Tarea Pesada"),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:
                                isComputing ? null : llamarTareaPesadaCompute,
                            child: const Text("Tarea Pesada en Compute"),
                          ),
                        ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

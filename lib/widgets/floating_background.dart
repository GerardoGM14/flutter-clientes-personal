import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class FloatingBackground extends StatefulWidget {
  const FloatingBackground({super.key});

  @override
  State<FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingBackgroundState extends State<FloatingBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  final Random _random = Random();

  // Tamaños definidos como pidió el usuario
  final List<double> _fixedSizes = [40.0, 60.0, 80.0, 100.0, 120.0];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 20 + _random.nextInt(15)), // Rotación suave constante
      )..repeat(reverse: false);
    });

    _animations = _controllers.map((controller) {
      // Movimiento de flotación muy suave
      return Tween<Offset>(
        begin: Offset(_random.nextDouble() * 1.8 - 0.9, _random.nextDouble() * 1.8 - 0.9),
        end: Offset(_random.nextDouble() * 1.8 - 0.9, _random.nextDouble() * 1.8 - 0.9),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.stop();
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo base limpio
        Container(color: const Color(0xFFFAFBFC)),
        
        ...List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _controllers[index],
            builder: (context, child) {
              return Align(
                alignment: Alignment(
                  _animations[index].value.dx,
                  _animations[index].value.dy,
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    // Eliminada la perspectiva (setEntry) para evitar el efecto de "respiración"
                    ..rotateX(_controllers[index].value * 2 * pi)
                    ..rotateY(_controllers[index].value * 2 * pi)
                    ..rotateZ(_controllers[index].value * pi), // Rotación completa en varios ejes
                  child: _buildTrue3DCube(index),
                ),
              );
            },
          );
        }),
        
        // Desenfoque para integrar con el fondo (efecto "dreamy")
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Menos blur para que se noten más
          child: Container(
            color: Colors.white.withOpacity(0.1), // Menos capa blanca para que se vean más los cubos
          ),
        ),
      ],
    );
  }

  Widget _buildTrue3DCube(int index) {
    // Tonos de gris (plomo)
    final colors = [
      Colors.grey[400]!,
      Colors.blueGrey[200]!,
      Colors.grey[300]!,
      Colors.blueGrey[100]!,
      Colors.grey[500]!,
    ];

    // Usar tamaño fijo de la lista o fallback si el índice excede
    double size = _fixedSizes[index % _fixedSizes.length];
    Color baseColor = colors[index % colors.length];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Cara Trasera
          Transform(
            transform: Matrix4.identity()..translate(0.0, 0.0, -size/2),
            alignment: Alignment.center,
            child: _buildFace(size, baseColor.withOpacity(0.8)),
          ),
          // Cara Frontal
          Transform(
            transform: Matrix4.identity()..translate(0.0, 0.0, size/2),
            alignment: Alignment.center,
            child: _buildFace(size, baseColor.withOpacity(0.9)),
          ),
          // Cara Izquierda
          Transform(
            transform: Matrix4.identity()
              ..translate(-size/2, 0.0, 0.0)
              ..rotateY(-pi / 2),
            alignment: Alignment.center,
            child: _buildFace(size, baseColor.withOpacity(0.85)),
          ),
          // Cara Derecha
          Transform(
            transform: Matrix4.identity()
              ..translate(size/2, 0.0, 0.0)
              ..rotateY(pi / 2),
            alignment: Alignment.center,
            child: _buildFace(size, baseColor.withOpacity(0.85)),
          ),
          // Cara Superior
          Transform(
            transform: Matrix4.identity()
              ..translate(0.0, -size/2, 0.0)
              ..rotateX(pi / 2),
            alignment: Alignment.center,
            child: _buildFace(size, baseColor.withOpacity(0.9)),
          ),
          // Cara Inferior
          Transform(
            transform: Matrix4.identity()
              ..translate(0.0, size/2, 0.0)
              ..rotateX(-pi / 2),
            alignment: Alignment.center,
            child: _buildFace(size, baseColor.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildFace(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), // Borde definido
      ),
    );
  }
}

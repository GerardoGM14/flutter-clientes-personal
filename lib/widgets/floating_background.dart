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

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 20 + _random.nextInt(15)),
      )..repeat(reverse: false); // Rotación continua
    });

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: Offset(_random.nextDouble() * 1.8 - 0.9, _random.nextDouble() * 1.8 - 0.9),
        end: Offset(_random.nextDouble() * 1.8 - 0.9, _random.nextDouble() * 1.8 - 0.9),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo limpio
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
                    ..setEntry(3, 2, 0.001) // Perspectiva
                    ..rotateX(_controllers[index].value * 2 * pi)
                    ..rotateY(_controllers[index].value * 2 * pi)
                    ..rotateZ(_controllers[index].value * 2 * pi),
                  child: _buildTrue3DCube(index),
                ),
              );
            },
          );
        }),
        
        // Desenfoque sutil (comentado temporalmente para pruebas de visibilidad si es necesario, 
        // pero lo dejamos suave para que se noten los cubos)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reducimos blur para ver mejor
          child: Container(
            color: Colors.white.withOpacity(0.1), // Menos opacidad blanca
          ),
        ),
      ],
    );
  }

  Widget _buildTrue3DCube(int index) {
    final colors = [
      const Color(0xFF2196F3), // Azul más fuerte
      const Color(0xFF4CAF50), // Verde más fuerte
      const Color(0xFFFF9800), // Naranja más fuerte
      const Color(0xFF9C27B0), // Violeta más fuerte
      const Color(0xFFF44336), // Rojo más fuerte
    ];

    double size = 60.0 + _random.nextInt(40); // Un poco más pequeños para que se muevan mejor
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
            child: _buildFace(size, baseColor.withOpacity(0.8)), // Más opacidad
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
        border: Border.all(color: Colors.white, width: 2), // Borde blanco sólido
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ]
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../screens/clientes_screen.dart';
import '../screens/trabajos_screen.dart';

class CustomFabMenu extends StatefulWidget {
  const CustomFabMenu({super.key});

  @override
  State<CustomFabMenu> createState() => _CustomFabMenuState();
}

class _CustomFabMenuState extends State<CustomFabMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        curve: Curves.easeOut,
        parent: _controller,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!mounted) return;
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _navigateTo(Widget page) {
    _toggle(); // Cerrar menú
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end, // Alinear a la derecha
      children: [
        // Opción 3: Trabajos
        _buildMenuOption(
          icon: Icons.work_outline,
          label: "Trabajos",
          color: AppTheme.pastelOrange,
          delay: 2,
          onTap: () => _navigateTo(const TrabajosScreen()),
        ),
        
        // Opción 2: Clientes
        _buildMenuOption(
          icon: Icons.people_outline,
          label: "Clientes",
          color: AppTheme.pastelBlue,
          delay: 1,
          onTap: () => _navigateTo(const ClientesScreen()),
        ),

        // Opción 1: Dashboard (Recarga o Info)
        _buildMenuOption(
          icon: Icons.dashboard_outlined,
          label: "Dashboard",
          color: AppTheme.pastelGreen,
          delay: 0,
          onTap: () {
             _toggle();
             // Si ya estamos en dashboard, quizás solo scroll up o refresh
          },
        ),

        const SizedBox(height: 10),

        // Botón Principal
        FloatingActionButton(
          heroTag: "fab_menu_plus",
          onPressed: _toggle,
          backgroundColor: AppTheme.textDark,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    // Calculamos una escala escalonada basada en la animación
    // Usamos Interval para que salgan uno tras otro ligeramente
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.0,
        1.0, // Podríamos ajustar intervalos para efecto cascada (0.0 a 0.8, etc)
        curve: Curves.easeOut,
      ),
    );

    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Etiqueta de texto
            Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Botón Circular Pequeño
            FloatingActionButton.small(
              heroTag: null, // Evitar conflictos de Hero
              onPressed: onTap,
              backgroundColor: color,
              elevation: 2,
              child: Icon(icon, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

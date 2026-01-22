import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class TrabajosScreen extends StatelessWidget {
  const TrabajosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Trabajos", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 80, color: AppTheme.pastelOrange),
            const SizedBox(height: 20),
            Text("Aquí asignarás trabajos a tus clientes", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

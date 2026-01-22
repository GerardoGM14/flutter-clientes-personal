import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/trabajo.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: Todos, 1: Pendientes, 2: Pagados

  // Datos de ejemplo
  final List<Trabajo> trabajos = [
    Trabajo(
      cliente: "Marta López",
      descripcion: "Diseño de Logotipo",
      fechaEntrega: DateTime.now().subtract(const Duration(days: 2)),
      pago: 150.00,
      colorTarjeta: AppTheme.pastelOrange,
    ),
    Trabajo(
      cliente: "Restaurante El Sol",
      descripcion: "Fotografía de Menú",
      fechaEntrega: DateTime.now(),
      pago: 320.50,
      colorTarjeta: AppTheme.pastelLime,
    ),
    Trabajo(
      cliente: "Juan Pérez",
      descripcion: "Web Personal",
      fechaEntrega: DateTime.now().add(const Duration(days: 5)),
      pago: 500.00,
      colorTarjeta: AppTheme.pastelLavender,
    ),
     Trabajo(
      cliente: "Ana García",
      descripcion: "Campaña Redes Sociales",
      fechaEntrega: DateTime.now().add(const Duration(days: 1)),
      pago: 200.00,
      colorTarjeta: AppTheme.pastelPink,
    ),
     Trabajo(
      cliente: "Tech Solutions",
      descripcion: "App Móvil MVP",
      fechaEntrega: DateTime.now().add(const Duration(days: 10)),
      pago: 1200.00,
      colorTarjeta: AppTheme.pastelBlue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Fijo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: _buildHeader(),
            ),

            // 2. Filtros Tipo Píldora
            SizedBox(
              height: 40, // Altura mucho más reducida
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildTabPill("Todos", 0),
                  const SizedBox(width: 12),
                  _buildTabPill("Pendientes", 1),
                  const SizedBox(width: 12),
                  _buildTabPill("Pagados", 2),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // 3. Contenido Desplazable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección Destacada (Estadísticas Grandes)
                    _buildHeroCard(),
                    
                    const SizedBox(height: 30),
                    
                    Text(
                      "Historial de Trabajos",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lista tipo Timeline
                    ...trabajos.map((trabajo) => _buildTimelineItem(trabajo)),
                    
                    const SizedBox(height: 80), // Espacio final
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Botón flotante estilizado
      floatingActionButton: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: AppTheme.textDark,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textDark.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, Creativo",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Tu Dashboard",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.pastelLavender,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTabPill(String text, int index) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Sin padding vertical extra, centrado por el contenedor
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              height: 1.0, // Interlineado compacto para centrado perfecto
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.pastelBlue, // Cyan suave
        borderRadius: BorderRadius.circular(40), // Bordes muy redondeados
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph, color: AppTheme.textDark),
              ),
              const Icon(Icons.more_horiz, color: AppTheme.textDark),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ganancias Totales",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.textDark.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "\$ 2,450.00",
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  height: 1.0, // Muy compacto para números grandes
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildMiniStat("Proyectos", "5"),
              const SizedBox(width: 20),
              _buildMiniStat("Horas", "42h"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textDark.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(Trabajo trabajo) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna Izquierda: Hora/Fecha + Línea
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  DateFormat('d').format(trabajo.fechaEntrega),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(trabajo.fechaEntrega).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
          ),
          
          // Columna Derecha: Tarjeta
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: trabajo.colorTarjeta.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trabajo.cliente,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textDark.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trabajo.descripcion,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "\$${trabajo.pago.toInt()}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

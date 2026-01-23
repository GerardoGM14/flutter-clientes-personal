import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import '../models/trabajo.dart';
import '../widgets/custom_fab_menu.dart'; // Importamos el menú animado
import '../widgets/floating_background.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: Todos, 1: Pendientes, 2: Pagados
  int _currentCardIndex = 0; // Índice para el carrusel de tarjetas
  int _currentBottomNavIndex = 0; // 0: Home, 1: Clientes

  // Calendario y Filtros
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _filterType = "Todos"; // Todos, Por Fecha, Por Cliente
  String? _selectedClient; // Cliente seleccionado para el filtro
  bool? _isDropdownOpen = false; // Estado del dropdown personalizado

  // Perfil de Usuario
  String _userName = "Creativo";
  int _selectedAvatarIndex = 0;
  File? _profileImage; // Imagen de perfil personalizada
  int _touchedIndex = -1; // Para la animación del gráfico circular
  
  // Usamos getter para evitar problemas de Hot Reload con listas nuevas
  List<Color> get _avatarColors => [
    AppTheme.pastelLavender,
    AppTheme.pastelBlue,
    AppTheme.pastelOrange,
    AppTheme.pastelPink,
    AppTheme.pastelLime,
  ];

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

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Editar Perfil",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _userName,
                  decoration: InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onChanged: (val) => _userName = val,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _profileImage = File(image.path);
                        _selectedAvatarIndex = -1; // Deseleccionar avatares de color
                      });
                      setStateModal(() {}); // Actualizar el modal
                    }
                  },
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                            image: _profileImage != null
                                ? DecorationImage(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: _profileImage == null
                              ? Icon(Icons.camera_alt, color: Colors.grey[400], size: 40)
                              : null,
                        ),
                        if (_profileImage != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.textDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "O elige un Avatar",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_avatarColors.length, (index) {
                    final isSelected = _selectedAvatarIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarIndex = index;
                          _profileImage = null; // Quitar imagen personalizada si elige color
                        });
                        setStateModal(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: AppTheme.textDark, width: 2) : null,
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _avatarColors[index],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Guardar",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFlashSummary() {
    // Cálculos rápidos
    final now = DateTime.now();
    final earningsToday = trabajos
        .where((t) => isSameDay(t.fechaEntrega, now))
        .fold(0.0, (sum, t) => sum + t.pago);
    
    final urgentJobs = trabajos.where((t) {
      final difference = t.fechaEntrega.difference(now).inDays;
      return difference >= 0 && difference <= 2;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppTheme.pastelBlue.withOpacity(0.15), // Tinte suave de color
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: 600, // Taller for better layout
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Stack(
              children: [
                // Decorative Background Shapes
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: AppTheme.pastelBlue.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.pastelOrange.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        "Resumen Flash",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          height: 1.1,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Earnings Card (Aurora Style)
                      _buildAuroraCard(
                        color: AppTheme.pastelGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Ganancias Hoy",
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "\$${earningsToday.toStringAsFixed(2)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.pastelGreen.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.attach_money, color: AppTheme.textDark, size: 32),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Split Layout: Image (Left) + Tasks (Right)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Left: Large Mascot Image
                            SizedBox(
                              width: 180,
                              height: 280,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomLeft,
                                children: [
                                  // Subtle glow behind image
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        color: AppTheme.pastelOrange.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.pastelOrange.withOpacity(0.3),
                                            blurRadius: 30,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // The Image
                                  Positioned(
                                    bottom: 0,
                                    left: -20, // Pull slightly off-screen for dynamic look
                                    child: SizedBox(
                                      width: 240, // Much larger
                                      child: Image.asset(
                                        "assets/images/man_happy.png",
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Right: Urgent Tasks List
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                                    child: Text(
                                      "Urgentes",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: urgentJobs.isEmpty
                                      ? Center(
                                          child: Text(
                                            "Todo al día 🎉",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[400],
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          itemCount: urgentJobs.length,
                                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                                          itemBuilder: (context, index) {
                                            final job = urgentJobs[index];
                                            return Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: AppTheme.pastelBlue.withOpacity(0.1)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.pastelBlue.withOpacity(0.1),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    job.descripcion,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppTheme.textDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Entrega: ",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                      Text(
                                                        "${job.fechaEntrega.day}/${job.fechaEntrega.month}",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          color: AppTheme.pastelOrange,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.textDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Entendido",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: FloatingBackground()),
          SafeArea(
            child: _currentBottomNavIndex == 0 
                ? _buildDashboardView()
                : _buildClientsView(),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.textDark,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.4),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _currentBottomNavIndex.clamp(0, 2),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            if (index == 2) {
              _showEditProfileModal();
            } else {
              setState(() {
                _currentBottomNavIndex = index;
              });
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Clientes"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "fab_quick_actions",
              onPressed: () {
                _showFlashSummary();
              },
              backgroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.bolt, color: AppTheme.textDark),
            ),
            const CustomFabMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuroraCard({
    required Widget child,
    required Color color,
    double? height,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    // Definir paleta dinámica basada en el color de entrada
    Color baseColor = color;
    Color accentColor1;
    Color accentColor2;

    // Lógica de mezcla de colores pasteles
    if (color.value == AppTheme.pastelGreen.value) {
      // Caso Verde: Verde Pastel + Verde Agua + Amarillo Pastel
      baseColor = AppTheme.pastelGreen;
      accentColor1 = AppTheme.pastelBlue; // Verde agua/Cyan
      accentColor2 = const Color(0xFFFFFAC8); // Amarillo Pastel Suave
    } else if (color.value == AppTheme.pastelBlue.value) {
      // Caso Azul: Azul Pastel + Lavanda + Blanco
      baseColor = AppTheme.pastelBlue;
      accentColor1 = AppTheme.pastelLavender;
      accentColor2 = Colors.white;
    } else if (color.value == AppTheme.pastelOrange.value) {
      // Caso Naranja: Naranja Pastel + Amarillo + Rosa
      baseColor = AppTheme.pastelOrange;
      accentColor1 = const Color(0xFFFFFAC8); // Amarillo
      accentColor2 = AppTheme.pastelPink;
    } else {
      // Default
      accentColor1 = Colors.white;
      accentColor2 = color.withOpacity(0.5);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // Borde con efecto de "cortes" de luz (White -> Transparent -> White)
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.0), // Transparente en el medio para mostrar el fondo
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withOpacity(0.12), // Sombra aún más sutil
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white, // Fondo base BLANCO para evitar oscuridad
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            children: [
              // Capa de Gradiente Pastel MUY suave sobre el blanco
              Container(
                decoration: BoxDecoration(
                   gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      baseColor.withOpacity(0.15), // Color muy suave
                      accentColor1.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              
              // Mancha 1: Verde Agua (Top Left)
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor1.withOpacity(0.4), // Un poco más fuerte para que se note el gradiente
                  ),
                ),
              ),
              // Mancha 2: Verde Pastel (Bottom Right)
              Positioned(
                bottom: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: baseColor.withOpacity(0.4),
                  ),
                ),
              ),
              // Mancha 3: Destello Amarillo (Center/Floating)
              Positioned(
                top: 30,
                right: 50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor2.withOpacity(0.4), // Amarillo más brillante
                    boxShadow: [
                      BoxShadow(
                        color: accentColor2.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
               // Mancha 4: Acento extra
              Positioned(
                bottom: 50,
                left: 30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor1.withOpacity(0.25),
                  ),
                ),
              ),
              // Blur Mesh para mezclar todo suavemente
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: padding ?? const EdgeInsets.all(24),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          child: _buildHeader(title: "Tu Dashboard"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(child: _buildTabPill("Todos", 0)),
              const SizedBox(width: 12),
              Expanded(child: _buildTabPill("Pendientes", 1)),
              const SizedBox(width: 12),
              Expanded(child: _buildTabPill("Pagados", 2)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 30),
                _buildActivityChart(),
                const SizedBox(height: 30),
                _buildCategoryPieChart(),
                const SizedBox(height: 30),
                _buildMonthlyGoals(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            "Metas Mensuales",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildGoalItem("Ingresos", 2450, 3000, AppTheme.pastelGreen),
              const SizedBox(height: 20),
              _buildGoalItem("Proyectos", 5, 8, AppTheme.pastelBlue),
              const SizedBox(height: 20),
              _buildGoalItem("Nuevos Clientes", 2, 5, AppTheme.pastelOrange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalItem(String title, double current, double target, Color color) {
    final double progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${current.toInt()} / ${target.toInt()}",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientsView() {
    // Lógica de Filtrado
    List<Trabajo> filteredTrabajos = trabajos;
    List<Trabajo> calendarEvents = trabajos; // Eventos para el calendario
    
    if (_filterType == "Por Fecha" && _selectedDay != null) {
      filteredTrabajos = trabajos.where((t) {
        return isSameDay(t.fechaEntrega, _selectedDay);
      }).toList();
    } else if (_filterType == "Por Cliente") {
      if (_selectedClient != null) {
        filteredTrabajos = trabajos.where((t) => t.cliente == _selectedClient).toList();
        calendarEvents = filteredTrabajos;
      }
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: _buildHeader(title: "Tus Trabajos"),
          ),
        ),
        
        // Calendario
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                formatAnimationDuration: const Duration(milliseconds: 500),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mes',
                  CalendarFormat.week: 'Semana',
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _filterType = "Por Fecha"; // Activar filtro automáticamente
                    _selectedClient = null;
                    _calendarFormat = CalendarFormat.week;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.pastelBlue.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.textDark,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.pastelOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.textDark),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.textDark),
                ),
                eventLoader: (day) {
                  return calendarEvents.where((t) => isSameDay(t.fechaEntrega, day)).toList();
                },
              ),
            ),
          ),
        ),

        // Filtros Animados
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: _buildFilterChip("Todos", _filterType == "Todos")),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterChip("Por Fecha", _filterType == "Por Fecha")),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterChip("Por Cliente", _filterType == "Por Cliente")),
              ],
            ),
          ),
        ),
        
        // Selector de Cliente
        SliverToBoxAdapter(child: _buildClientSelector()),

        if (_filterType == "Por Cliente" && _selectedClient == null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.touch_app_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      "Selecciona un cliente arriba",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (filteredTrabajos.isEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  "No hay trabajos para esta selección",
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) return const SizedBox(height: 20);
                if (index == filteredTrabajos.length + 1) return const SizedBox(height: 80);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildTimelineItem(filteredTrabajos[index - 1]),
                );
              },
              childCount: filteredTrabajos.length + 2,
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = label;
          if (label == "Todos") {
            _selectedDay = null;
            _selectedClient = null;
            _calendarFormat = CalendarFormat.week;
          } else if (label == "Por Fecha") {
            _selectedClient = null;
          } else if (label == "Por Cliente") {
            _selectedDay = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildClientSelector() {
    if (_filterType != "Por Cliente") return const SizedBox.shrink();

    final clients = trabajos.map((t) => t.cliente).toSet().toList();

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !(_isDropdownOpen ?? false);
            });
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedClient ?? "Selecciona un cliente",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: _selectedClient != null ? AppTheme.textDark : Colors.grey,
                    fontSize: 16,
                  ),
                ),
                AnimatedRotation(
                  turns: (_isDropdownOpen ?? false) ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textDark),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            height: (_isDropdownOpen ?? false) ? null : 0,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Column(
                children: clients.map((client) {
                  final isSelected = client == _selectedClient;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedClient = client;
                          _isDropdownOpen = false;
                          _calendarFormat = CalendarFormat.month;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade100),
                          ),
                          color: isSelected ? AppTheme.pastelBlue.withOpacity(0.1) : null,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.pastelBlue, // Podríamos usar un color único por cliente
                              child: Text(
                                client[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              client,
                              style: GoogleFonts.poppins(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: AppTheme.textDark,
                              ),
                            ),
                            if (isSelected) ...[
                              const Spacer(),
                              const Icon(Icons.check, color: AppTheme.textDark, size: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({String title = "Tu Dashboard"}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, $_userName",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _showEditProfileModal,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _profileImage != null
                ? CircleAvatar(
                    radius: 24,
                    backgroundImage: FileImage(_profileImage!),
                  )
                : CircleAvatar(
                    radius: 24,
                    backgroundColor: _avatarColors[_selectedAvatarIndex],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
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
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    // Datos de las tarjetas para el carrusel
    final List<Map<String, dynamic>> cards = [
      {
        "title": "Ganancias Totales",
        "value": "\$ 2,450.00",
        "color": AppTheme.pastelBlue,
        "icon": Icons.auto_graph,
        "stats": [
          {"label": "Proyectos", "value": "5"},
          {"label": "Horas", "value": "42h"},
        ]
      },
      {
        "title": "Trabajos Activos",
        "value": "3",
        "color": AppTheme.pastelOrange,
        "icon": Icons.work_outline,
        "stats": [
          {"label": "Pendientes", "value": "2"},
          {"label": "Urgentes", "value": "1"},
        ]
      },
      {
        "title": "Próximos Pagos",
        "value": "\$ 850.00",
        "color": AppTheme.pastelGreen,
        "icon": Icons.attach_money,
        "stats": [
          {"label": "En 7 días", "value": "\$300"},
          {"label": "En 15 días", "value": "\$550"},
        ]
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: PageController(viewportFraction: 1.0),
            physics: const BouncingScrollPhysics(),
            itemCount: cards.length,
            onPageChanged: (index) {
              setState(() {
                _currentCardIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final card = cards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildAuroraCard(
                  color: card["color"],
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              card["title"],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (card["color"] as Color).withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(card["icon"], color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      Text(
                        card["value"],
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          height: 1.0,
                        ),
                      ),
                      if (card["hasProgress"] == true) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: card["progress"],
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textDark),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${(card["progress"] * 100).toInt()}%",
                                  style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 30,
                                child: Stack(
                                  children: List.generate((card["avatars"] as List).length, (idx) {
                                    return Positioned(
                                      left: idx * 20.0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: card["avatars"][idx],
                                          child: const Icon(Icons.person, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              Text(
                                "+2 más",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.textDark.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ] else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: (card["stats"] as List).map<Widget>((stat) {
                          return _buildMiniStat(stat["label"], stat["value"]);
                        }).toList(),
                      )
                  ],
                ),
              ),
            );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Indicadores de página animados
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cards.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentCardIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentCardIndex == index 
                    ? AppTheme.textDark 
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
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

  Widget _buildActivityChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            "Resumen de Actividad",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                rotationQuarterTurns: 1,
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(
                  enabled: false,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.transparent,
                    tooltipPadding: EdgeInsets.zero,
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        GoogleFonts.poppins(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Color(0xff7589a2),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'Lun';
                            break;
                          case 1:
                            text = 'Mar';
                            break;
                          case 2:
                            text = 'Mié';
                            break;
                          case 3:
                            text = 'Jue';
                            break;
                          case 4:
                            text = 'Vie';
                            break;
                          case 5:
                            text = 'Sáb';
                            break;
                          case 6:
                            text = 'Dom';
                            break;
                          default:
                            text = '';
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  _makeBarGroup(0, 5, AppTheme.pastelBlue),
                  _makeBarGroup(1, 10, AppTheme.pastelOrange),
                  _makeBarGroup(2, 14, AppTheme.pastelPink),
                  _makeBarGroup(3, 15, AppTheme.pastelLime),
                  _makeBarGroup(4, 13, AppTheme.pastelLavender),
                  _makeBarGroup(5, 10, AppTheme.pastelGreen),
                  _makeBarGroup(6, 16, AppTheme.pastelBlue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  Widget _buildCategoryPieChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            "Distribución de Proyectos",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 250, // Aumentamos altura para dar espacio a la animación
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Texto Central
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Total",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "25",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                return;
                              }
                              if (event is FlTapUpEvent) {
                                final newIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                if (_touchedIndex == newIndex) {
                                  _touchedIndex = -1;
                                } else {
                                  _touchedIndex = newIndex;
                                }
                              }
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 4, // Espacio entre secciones
                        centerSpaceRadius: 60, // Centro más grande
                        sections: _showingSections(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _touchedIndex == -1 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(AppTheme.pastelBlue, "Diseño"),
                        const SizedBox(width: 24),
                        _buildLegendItem(AppTheme.pastelOrange, "Dev"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(AppTheme.pastelPink, "MKT"),
                        const SizedBox(width: 24),
                        _buildLegendItem(AppTheme.pastelLime, "Foto"),
                      ],
                    ),
                  ],
                ),
                secondChild: _buildSelectedCategoryDetails(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedCategoryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade200),
        const SizedBox(height: 10),
        Text(
          _getCategoryName(_touchedIndex),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        ..._getCategoryJobs(_touchedIndex).map((trabajo) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTimelineItem(trabajo),
            )),
        if (_getCategoryJobs(_touchedIndex).isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "No hay trabajos recientes",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  String _getCategoryName(int index) {
    switch (index) {
      case 0: return "Diseño";
      case 1: return "Desarrollo";
      case 2: return "Marketing";
      case 3: return "Fotografía";
      default: return "";
    }
  }

  List<Trabajo> _getCategoryJobs(int index) {
    Color targetColor;
    switch (index) {
      case 0: targetColor = AppTheme.pastelBlue; break;
      case 1: targetColor = AppTheme.pastelOrange; break;
      case 2: targetColor = AppTheme.pastelPink; break;
      case 3: targetColor = AppTheme.pastelLime; break;
      default: return [];
    }
    // Filtramos trabajos que coincidan con el color de la categoría
    // Nota: En una app real usarías un ID de categoría, aquí usamos el color por simplicidad
    return trabajos.where((t) => t.colorTarjeta == targetColor).toList();
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppTheme.pastelBlue,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppTheme.pastelOrange,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: AppTheme.pastelPink,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: AppTheme.pastelLime,
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          );
        default:
          throw Error();
      }
    });
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textDark.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(Trabajo trabajo) {
    return Stack(
      children: [
        // Línea vertical (Fondo)
        Positioned(
          left: 24,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            color: Colors.grey.shade200,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna Izquierda: Fecha
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Columna Derecha: Tarjeta
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(10), // Borde blanco "grande"
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.lerp(trabajo.colorTarjeta, Colors.white, 0.2)!.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              trabajo.cliente,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.textDark.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trabajo.descripcion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6), // Más sutil dentro del color
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "\$${trabajo.pago.toInt()}",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.icon, {
    required this.size,
    required this.borderColor,
  });
  final IconData icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: FittedBox(
          child: Icon(
            icon,
            color: AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}

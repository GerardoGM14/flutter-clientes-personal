import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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

  // Perfil de Usuario
  String _userName = "Creativo";
  int _selectedAvatarIndex = 0;
  
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
                Text(
                  "Elige un Avatar",
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
                        setStateModal(() {
                          _selectedAvatarIndex = index;
                        });
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
      floatingActionButton: const CustomFabMenu(),
    );
  }

  Widget _buildDashboardView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          child: _buildHeader(title: "Tu Dashboard"),
        ),
        SizedBox(
          height: 40,
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
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                ...trabajos.map((trabajo) => _buildTimelineItem(trabajo)),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientsView() {
    // Lógica de Filtrado
    List<Trabajo> filteredTrabajos = trabajos;
    
    if (_selectedDay != null && _filterType == "Por Fecha") {
      filteredTrabajos = trabajos.where((t) {
        return isSameDay(t.fechaEntrega, _selectedDay);
      }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: _buildHeader(title: "Tus Trabajos"),
        ),
        
        // Calendario
        Container(
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
              return trabajos.where((t) => isSameDay(t.fechaEntrega, day)).toList();
            },
          ),
        ),

        // Filtros Animados
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildFilterChip("Todos", _filterType == "Todos"),
              const SizedBox(width: 12),
              _buildFilterChip("Por Fecha", _filterType == "Por Fecha"),
              const SizedBox(width: 12),
              _buildFilterChip("Por Cliente", _filterType == "Por Cliente"),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                if (filteredTrabajos.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        "No hay trabajos para esta fecha",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...filteredTrabajos.map((trabajo) => _buildTimelineItem(trabajo)),
                const SizedBox(height: 80),
              ],
            ),
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
            _selectedDay = null; // Limpiar selección de fecha
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.textDark.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
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
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: _avatarColors[_selectedAvatarIndex],
            child: const Icon(Icons.person, color: Colors.white),
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
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: card["color"],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: (card["color"] as Color).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
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
                            color: Colors.white.withOpacity(0.3),
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
                                    backgroundColor: Colors.white.withOpacity(0.5),
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
                        children: (card["stats"] as List).map<Widget>((stat) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: _buildMiniStat(stat["label"], stat["value"]),
                          );
                        }).toList(),
                      )
                  ],
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: trabajo.colorTarjeta.withOpacity(0.5),
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
                              fontSize: 14,
                              color: AppTheme.textDark.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trabajo.descripcion,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
      ],
    );
  }
}

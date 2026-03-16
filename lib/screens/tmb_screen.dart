import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tmb_provider.dart';

/// VISTA: Pantalla de transporte público TMB
class TMBScreen extends StatefulWidget {
  const TMBScreen({super.key});

  @override
  State<TMBScreen> createState() => _TMBScreenState();
}

class _TMBScreenState extends State<TMBScreen> with SingleTickerProviderStateMixin {
  final _stopCodeController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Cargar líneas al iniciar
    Future.microtask(
      () => Provider.of<TMBProvider>(context, listen: false).loadAllLines(),
    );
  }

  @override
  void dispose() {
    _stopCodeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _searchStop() {
    final code = _stopCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un código de parada')),
      );
      return;
    }

    Provider.of<TMBProvider>(context, listen: false).searchStop(code);
    _tabController.animateTo(0); // Ir a pestaña de paradas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('🚌 TMB Barcelona'),
        elevation: 0,
      ),
      body: Consumer<TMBProvider>(
        builder: (context, tmbProvider, child) {
          return Column(
            children: [
              // Barra de búsqueda
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _stopCodeController,
                      decoration: InputDecoration(
                        hintText: 'Ej: 1234 (código de parada)',
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _stopCodeController.clear(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _searchStop(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _searchStop,
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar Parada'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.location_on), text: 'Paradas'),
                  Tab(icon: Icon(Icons.directions_bus), text: 'Líneas'),
                ],
              ),
              // Contenido de pestañas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Pestaña 1: Paradas y Autobuses
                    _buildStopsAndBusesTab(tmbProvider),
                    // Pestaña 2: Líneas
                    _buildLinesTab(tmbProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Pestaña 1: Mostrar paradas y autobuses
  Widget _buildStopsAndBusesTab(TMBProvider tmbProvider) {
    // Si hay una parada seleccionada, mostrar autobuses
    if (tmbProvider.selectedStop != null) {
      return _buildBusesView(tmbProvider);
    }

    // Si está cargando paradas
    if (tmbProvider.isLoadingStops) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si hay error en paradas
    if (tmbProvider.errorStops != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              tmbProvider.errorStops!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _stopCodeController.clear(),
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ),
      );
    }

    // Lista de paradas encontradas
    if (tmbProvider.stops.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tmbProvider.stops.length,
        itemBuilder: (context, index) {
          final stop = tmbProvider.stops[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.location_on, color: Colors.white),
              ),
              title: Text(
                stop.stopName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('ID: ${stop.stopId}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Provider.of<TMBProvider>(context, listen: false)
                    .getBusesAtStop(stop);
              },
            ),
          );
        },
      );
    }

    // Estado inicial
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Introduce un código de parada',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Vista de autobuses en una parada
  Widget _buildBusesView(TMBProvider tmbProvider) {
    return Column(
      children: [
        // Header con parada seleccionada
        Container(
          color: Colors.blue.withOpacity(0.1),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Provider.of<TMBProvider>(context, listen: false)
                          .reset();
                      _stopCodeController.clear();
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tmbProvider.selectedStop!.stopName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Parada: ${tmbProvider.selectedStop!.stopId}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Contenido de autobuses
        Expanded(
          child: _buildBusesContent(tmbProvider),
        ),
      ],
    );
  }

  /// Contenido de autobuses
  Widget _buildBusesContent(TMBProvider tmbProvider) {
    // Cargando
    if (tmbProvider.isLoadingBuses) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (tmbProvider.errorBuses != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              tmbProvider.errorBuses!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    // Lista de autobuses
    if (tmbProvider.buses.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tmbProvider.buses.length,
        itemBuilder: (context, index) {
          final bus = tmbProvider.buses[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Número de línea
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      bus.routeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Información del autobús
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.destination,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          bus.busStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tiempo de llegada
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${bus.arrivalMinutes}'",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'min',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const Center(
      child: Text('Sin autobuses disponibles'),
    );
  }

  /// Pestaña 2: Mostrar líneas disponibles
  Widget _buildLinesTab(TMBProvider tmbProvider) {
    // Cargando
    if (tmbProvider.isLoadingLines) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (tmbProvider.errorLines != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              tmbProvider.errorLines!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    // Lista de líneas
    if (tmbProvider.lines.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tmbProvider.lines.length,
        itemBuilder: (context, index) {
          final line = tmbProvider.lines[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  line.routeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                line.transportType,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: line.operator != null ? Text(line.operator!) : null,
            ),
          );
        },
      );
    }

    return const Center(
      child: Text('No hay líneas disponibles'),
    );
  }
}

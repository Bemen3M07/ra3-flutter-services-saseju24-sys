import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tmb_provider.dart';

/// VISTA: Pantalla de transport públic TMB
class TMBScreen extends StatefulWidget {
  const TMBScreen({super.key});

  @override
  State<TMBScreen> createState() => _TMBScreenState();
}

class _TMBScreenState extends State<TMBScreen>
    with SingleTickerProviderStateMixin {
  final _stopCodeController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Carrega les línies en iniciar (Endpoint 3)
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
        const SnackBar(content: Text('Introdueix un codi de parada')),
      );
      return;
    }
    Provider.of<TMBProvider>(context, listen: false).searchStop(code);
    _tabController.animateTo(0);
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
              // Barra de cerca (Endpoint 1)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _stopCodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 1234 (codi de parada)',
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
                        label: const Text('Cercar Parada'),
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
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.location_on), text: 'Parades'),
                  Tab(icon: Icon(Icons.directions_bus), text: 'Línies'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStopsAndBusesTab(tmbProvider),
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

  /// Pestanya 1: Parades i Autobusos
  Widget _buildStopsAndBusesTab(TMBProvider tmbProvider) {
    if (tmbProvider.selectedStop != null) {
      return _buildBusesView(tmbProvider);
    }

    if (tmbProvider.isLoadingStops) {
      return const Center(child: CircularProgressIndicator());
    }

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
              onPressed: () {
                Provider.of<TMBProvider>(context, listen: false).reset();
                _stopCodeController.clear();
              },
              child: const Text('Netejar cerca'),
            ),
          ],
        ),
      );
    }

    if (tmbProvider.stops.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tmbProvider.stops.length,
        itemBuilder: (context, index) {
          final stop = tmbProvider.stops[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.location_on, color: Colors.white),
              ),
              title: Text(
                stop.stopName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Codi: ${stop.stopId}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              // Endpoint 2: autobusos en temps real
              onTap: () => Provider.of<TMBProvider>(context, listen: false)
                  .getBusesAtStop(stop),
            ),
          );
        },
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Introdueix un codi de parada\ni prem Cercar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Vista de detall: autobusos d'una parada
  Widget _buildBusesView(TMBProvider tmbProvider) {
    return Column(
      children: [
        Container(
          color: Colors.blue.withValues(alpha: 0.1),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Provider.of<TMBProvider>(context, listen: false).reset();
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
                          fontSize: 18, fontWeight: FontWeight.bold),
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
        ),
        Expanded(child: _buildBusesContent(tmbProvider)),
      ],
    );
  }

  Widget _buildBusesContent(TMBProvider tmbProvider) {
    if (tmbProvider.isLoadingBuses) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tmbProvider.errorBuses != null) {
      return Center(
        child: Text(
          tmbProvider.errorBuses!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bus.destination,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          bus.busStatus,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
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
                              fontSize: 10, color: Colors.grey[600]),
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

    return const Center(child: Text('Sense autobusos disponibles'));
  }

  /// Pestanya 2: Línies de bus (Endpoint 3)
  Widget _buildLinesTab(TMBProvider tmbProvider) {
    if (tmbProvider.isLoadingLines) {
      return const Center(child: CircularProgressIndicator());
    }

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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  Provider.of<TMBProvider>(context, listen: false)
                      .loadAllLines(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  line.routeName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(line.transportType,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  line.operator != null ? Text(line.operator!) : null,
            ),
          );
        },
      );
    }

    return const Center(child: Text('No hi ha línies disponibles'));
  }
}

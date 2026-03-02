import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/car_provider.dart';

// VISTA: Pantalla de coches
class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los datos cuando se inicia la página
    Future.microtask(
      () => Provider.of<CarProvider>(context, listen: false).getCarsData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Cars List'),
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          if (carProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (carProvider.error != null) {
            return Center(
              child: Text(
                'Error: ${carProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (carProvider.cars.isEmpty) {
            return const Center(
              child: Text('No cars found'),
            );
          }

          return ListView.builder(
            itemCount: carProvider.cars.length,
            itemBuilder: (context, index) {
              final car = carProvider.cars[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${car.id}'),
                ),
                title: Text('${car.year} ${car.make} ${car.model}'),
                subtitle: Text(car.type),
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            },
          );
        },
      ),
    );
  }
}

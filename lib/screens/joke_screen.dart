import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/joke_provider.dart';

// VISTA: Interfaz de usuario para mostrar chistes (Ejercicio 3)
class JokeScreen extends StatefulWidget {
  const JokeScreen({super.key});

  @override
  State<JokeScreen> createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar el primer chiste cuando inicia la pantalla
    Future.microtask(
      () => Provider.of<JokeProvider>(context, listen: false).loadRandomJoke(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Random Joke Generator'),
      ),
      body: Consumer<JokeProvider>(
        builder: (context, jokeProvider, child) {
          // Mostrar spinner mientras carga
          if (jokeProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Mostrar error si hay
          if (jokeProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${jokeProvider.error}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => jokeProvider.loadRandomJoke(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Mostrar el chiste si está disponible
          if (jokeProvider.currentJoke != null) {
            final joke = jokeProvider.currentJoke!;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Etiqueta de tipo
                  Chip(
                    // CORRECCIÓN: withOpacity() deprecado → withValues()
                    backgroundColor:
                        Colors.deepPurple.withValues(alpha: 0.2),
                    label: Text(joke.type.toUpperCase()),
                  ),
                  const SizedBox(height: 32),

                  // Pregunta (Setup)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // CORRECCIÓN: withOpacity() deprecado → withValues()
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Q: Setup',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          joke.setup,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Respuesta (Punchline)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // CORRECCIÓN: withOpacity() deprecado → withValues()
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'A: Punchline',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          joke.punchline,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ID del chiste
                  Text(
                    'Joke ID: ${joke.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // Sin chiste aún
          return const Center(
            child: Text('No joke loaded yet'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Provider.of<JokeProvider>(context, listen: false).loadRandomJoke(),
        tooltip: 'Get another joke',
        child: const Icon(Icons.sentiment_very_satisfied),
      ),
    );
  }
}

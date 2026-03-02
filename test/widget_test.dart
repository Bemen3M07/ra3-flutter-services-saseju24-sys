import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hello_world/main.dart';
import 'package:flutter_hello_world/providers/car_provider.dart';
void main() {
  testWidgets('Cars app displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => CarProvider(),
        child: const MyApp(),
      ),
    );

    // Verificar que la AppBar se muestra
    expect(find.text('Cars List'), findsOneWidget);
    
    // Verificar que se muestra el CircularProgressIndicator mientras carga
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
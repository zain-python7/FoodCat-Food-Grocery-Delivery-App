import 'package:flutter/material.dart';
import '../../widgets/components.dart';
class VehicleDocumentsPage extends StatelessWidget {
 const VehicleDocumentsPage({super.key});
 @override Widget build(BuildContext context)=>const FeaturePage(
  title:'Vehicle & documents', subtitle:'Add your vehicle details and required documents.', items:['Vehicle type', 'Registration number', 'Driving licence', 'Vehicle documents'],
  action:'Save documents', icon:Icons.delivery_dining,
 );
}

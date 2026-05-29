import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'create_demand_screen.dart';

class DemandListScreen extends StatefulWidget {
  const DemandListScreen({super.key});

  @override
  State<DemandListScreen> createState() => _DemandListScreenState();
}
 
class _DemandListScreenState extends State<DemandListScreen> {
  List<dynamic> _demands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDemands();
  }
 
Future<void> _fetchDemands() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getDemands();
    if (result['success'] == true) {
      setState(() {
        _demands = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text("MY BOOKINGS (DEMANDS)", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)
        ),
        backgroundColor: const Color(AppConstants.primaryColor),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDemands,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _demands.isEmpty
                ? const Center(child: Text("No demands found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _demands.length,
                    itemBuilder: (context, index) {
                      final demand = _demands[index];
                      return _buildDemandCard(demand);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateDemandScreen()),
          );
          if (result == true) _fetchDemands();
        },
        backgroundColor: const Color(AppConstants.primaryColor),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NEW BOOKING", style: TextStyle(color: Colors.white)),
      ),
    );
  }
 
  Widget _buildDemandCard(Map<String, dynamic> d) {
    final status = d['status'] ?? 'Pending';
    Color statusColor = Colors.orange;
    if (status == 'Completed') statusColor = Colors.green;
    if (status == 'Cancelled') statusColor = Colors.red;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.description, color: statusColor),
        ),
        title: Text(
          "Demand #${d['demandNo']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Date: ${d['date'].toString().substring(0, 10)}"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Items Requested:", style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                ...(d['items'] as List? ?? []).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${item['lot']['item']['name']} (Lot #${item['lot']['lotNo']})"),
                      Text("${item['qty']} Bags", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

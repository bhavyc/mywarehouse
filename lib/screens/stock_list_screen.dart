import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  List<dynamic> _lots = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStock();
  }

  Future<void> _fetchStock({String query = ""}) async {
    setState(() => _isLoading = true);
    final result = await ApiService.getStock(query: query);
    if (result['success'] == true) {
      setState(() {
        _lots = result['data'];
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
        title: const Text("MY STOCK (LOTS)", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)
        ),
        backgroundColor: const Color(AppConstants.primaryColor),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(AppConstants.primaryColor),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _fetchStock(query: val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Lot No or Marka...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Stock List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchStock,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _lots.isEmpty
                      ? const Center(child: Text("No stock found"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: _lots.length,
                          itemBuilder: (context, index) {
                            final lot = _lots[index];
                            return _buildStockCard(lot);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> lot) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: const Color(AppConstants.primaryColor).withOpacity(0.1),
          child: const Icon(Icons.inventory, color: Color(AppConstants.primaryColor)),
        ),
        title: Text(
          "Lot #${lot['lotNo']}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text("${lot['item']['name']} | ${lot['marka'] ?? 'No Marka'}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${lot['balanceQty']}",
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: Color(AppConstants.primaryColor)
              ),
            ),
            const Text("Bags Left", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow("MR Number", lot['mrNo']),
                _buildDetailRow("Arrival Date", lot['arrivalDate'].toString().substring(0, 10)),
                _buildDetailRow("Received Qty", "${lot['receivedQty']} Bags"),
                _buildDetailRow("Unit Type", lot['unit']['name']),
                _buildDetailRow("Chamber", lot['chamber']?['name'] ?? 'Not Assigned'),
                _buildDetailRow("Location", "${lot['floor'] ?? ''} / ${lot['pole'] ?? ''}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CreateDemandScreen extends StatefulWidget {
  const CreateDemandScreen({super.key});

  @override
  State<CreateDemandScreen> createState() => _CreateDemandScreenState();
}

class _CreateDemandScreenState extends State<CreateDemandScreen> {
  List<dynamic> _availableLots = [];
  Map<String, dynamic>? _partyInfo;
  bool _isLoading = true;
  final Map<String, int> _selectedItems = {}; // lotId -> quantity

  @override
  void initState() {
    super.initState();
    _fetchAvailableStock();
  }

  Future<void> _fetchAvailableStock() async {
    final result = await ApiService.getAvailableStockForDemand();
    if (result['success'] == true) {
      setState(() {
        _availableLots = result['data'];
        _partyInfo = result['partyInfo'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitDemand() async {
    // Validation for Cash Parties
    if (_partyInfo?['paymentPreference'] == "Cash" && 
        (_partyInfo?['outstandingBalance'] ?? 0) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("CASH PARTY: Please clear your balance before booking."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one item")),
      );
      return;
    }

    final items = _selectedItems.entries
        .where((e) => e.value > 0)
        .map((e) => {'lotId': e.key, 'qty': e.value})
        .toList();

    if (items.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await ApiService.createDemand(items);
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking Request Submitted!"), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? "Failed to submit")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: const Text("NEW BOOKING", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(AppConstants.primaryColor),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Select items and enter quantity to release:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableLots.length,
                    itemBuilder: (context, index) {
                      final lot = _availableLots[index];
                      return _buildStockItem(lot);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitDemand,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_partyInfo?['paymentPreference'] == "Cash" && (_partyInfo?['outstandingBalance'] ?? 0) > 0)
                            ? Colors.red
                            : const Color(AppConstants.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        (_partyInfo?['paymentPreference'] == "Cash" && (_partyInfo?['outstandingBalance'] ?? 0) > 0)
                            ? "PAYMENT REQUIRED"
                            : "SUBMIT REQUEST",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStockItem(Map<String, dynamic> lot) {
    final String id = lot['id'];
    final int available = lot['availableQty'];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lot #${lot['lotNo']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${lot['itemName']} (${lot['chamberName']})", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                    child: Text("Available: $available Bags", style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Qty",
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  final qty = int.tryParse(val) ?? 0;
                  setState(() {
                    if (qty > available) {
                      _selectedItems.remove(id); // Reset state if invalid
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: Only $available bags available in Lot #${lot['lotNo']}")),
                      );
                    } else if (qty > 0) {
                      _selectedItems[id] = qty;
                    } else {
                      _selectedItems.remove(id);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

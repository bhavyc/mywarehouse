import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
 
class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  List<dynamic> _transactions = [];
  double _closingBalance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLedger();
  }

  Future<void> _fetchLedger() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getLedger();
    if (result['success'] == true && result['data'] != null) {
      setState(() {
        _transactions = result['data']['transactions'] ?? [];
        _closingBalance = double.tryParse(result['data']['closingBalance']?.toString() ?? '0') ?? 0;
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
        title: const Text("LEDGER STATEMENT", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)
        ),
        backgroundColor: const Color(AppConstants.primaryColor),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(AppConstants.primaryColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Closing Balance:",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "₹ $_closingBalance",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 22, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
  
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchLedger,
                    child: _transactions.isEmpty
                        ? const Center(child: Text("No transactions found"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(15),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final tx = _transactions[index];
                              return _buildTransactionCard(tx);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final bool isDebit = tx['type'] == 'Debit';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),

      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            //Icon based on type
            CircleAvatar(
              backgroundColor: isDebit ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              child: Icon(
                isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                color: isDebit ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            
            //Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['description'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx['date'].toString().substring(0, 10),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Amount & mode
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹ ${tx['amount']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDebit ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  isDebit ? "Dr" : "Cr",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

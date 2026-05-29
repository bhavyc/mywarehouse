import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import 'login_screen.dart';
import 'stock_list_screen.dart';
import 'ledger_screen.dart';
import 'demand_list_screen.dart';
import 'create_demand_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  int _currentIndex = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getDashboard();
    final noteResult = await ApiService.getNotifications();
    
    if (result['success'] == true) {
      setState(() {
        _dashboardData = result['data'];
        _unreadNotifications = noteResult['unreadCount'] ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationManager.currentLanguage,
      builder: (context, langCode, _) {
        return Scaffold(
          backgroundColor: const Color(AppConstants.backgroundColor),
          
          // 1. SIDEBAR (DRAWER)
          drawer: _buildDrawer(),

          appBar: AppBar(
            title: Text(TranslationManager.translate('my_warehouse'), 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, letterSpacing: 1.2)
            ),
            backgroundColor: const Color(AppConstants.primaryColor),
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())).then((_) => _fetchDashboardData()),
                  ),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text('$_unreadNotifications', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ],
          ),

          body: RefreshIndicator(
            onRefresh: _fetchDashboardData,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAccountStatus(),
                              const SizedBox(height: 25),
                              Text(TranslationManager.translate('main_services'), 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)
                              ),
                              const SizedBox(height: 15),
                              _buildServiceGrid(),
                              const SizedBox(height: 30),
                              _buildRecentActivityHeader(),
                              const SizedBox(height: 10),
                              _buildRecentActivityList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // 2. BOTTOM NAVIGATION BAR
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(icon: Icon(Icons.dashboard_rounded, color: _currentIndex == 0 ? const Color(AppConstants.primaryColor) : Colors.grey), onPressed: () => setState(() => _currentIndex = 0)),
                IconButton(icon: const Icon(Icons.inventory_2_rounded, color: Colors.grey), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockListScreen()))),
                const SizedBox(width: 40), // Space for FAB
                IconButton(icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.grey), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LedgerScreen()))),
                IconButton(icon: const Icon(Icons.assignment_rounded, color: Colors.grey), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DemandListScreen()))),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateDemandScreen())),
            backgroundColor: const Color(AppConstants.primaryColor),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: const BoxDecoration(
        color: Color(AppConstants.primaryColor),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Welcome,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text(_dashboardData?['party']['name'] ?? "Kisan Bhai", 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildAccountBadge(),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(TranslationManager.translate('total_bags'), "${_dashboardData?['stock']['totalBags'] ?? 0}"),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildHeaderStat(TranslationManager.translate('total_lots'), "${_dashboardData?['stock']['totalLots'] ?? 0}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildAccountStatus() {
    final bool isCash = _dashboardData?['party']['paymentPreference'] == "Cash";
    final double balance = double.parse(_dashboardData?['financials']['outstandingBalance'] ?? '0');
    final bool isDue = isCash && balance > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: (isDue ? Colors.red : Colors.green).withOpacity(0.1),
            child: Icon(isDue ? Icons.warning_rounded : Icons.account_balance_wallet, color: isDue ? Colors.red : Colors.green),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TranslationManager.translate('outstanding_balance'), style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("₹ ${_dashboardData?['financials']['outstandingBalance'] ?? 0}", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDue ? Colors.red : Colors.black87)
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LedgerScreen())),
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _buildServiceCard(TranslationManager.translate('my_stock'), Icons.inventory_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockListScreen()))),
        _buildServiceCard(TranslationManager.translate('ledger'), Icons.payments_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LedgerScreen()))),
        _buildServiceCard(TranslationManager.translate('bookings'), Icons.event_note_rounded, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DemandListScreen()))),
        _buildServiceCard(TranslationManager.translate('profile'), Icons.person_rounded, Colors.teal, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(AppConstants.primaryColor)),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Color(AppConstants.primaryColor))),
            accountName: Text(_dashboardData?['party']['name'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(TranslationManager.translate('verified_client')),
          ),
          ListTile(leading: const Icon(Icons.dashboard_outlined), title: Text(TranslationManager.translate('dashboard')), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(TranslationManager.translate('my_inventory')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StockListScreen()))),
          ListTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: Text(TranslationManager.translate('ledger_statement')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LedgerScreen()))),
          ListTile(leading: const Icon(Icons.assignment_outlined), title: Text(TranslationManager.translate('my_bookings')), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DemandListScreen()))),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined), 
            title: Text(TranslationManager.translate('settings')), 
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(TranslationManager.translate('logout'), style: const TextStyle(color: Colors.red)),
            onTap: () async {
              await ApiService.logout();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBadge() {
    final String type = _dashboardData?['party']['paymentPreference'] ?? 'Credit';
    final double balance = double.parse(_dashboardData?['financials']['outstandingBalance'] ?? '0');
    Color color = (type == "Cash" && balance > 0) ? Colors.red : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: color, width: 1)),
      child: Text(type.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(TranslationManager.translate('recent_activity'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
        TextButton(onPressed: () {}, child: Text(TranslationManager.translate('see_all'))),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    final activities = _dashboardData?['recentActivities']['inwards'] as List? ?? [];
    if (activities.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(TranslationManager.translate('no_recent_activity'))));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length > 3 ? 3 : activities.length,
      itemBuilder: (context, index) {
        final item = activities[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black12)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.1), child: const Icon(Icons.arrow_downward, color: Colors.green, size: 20)),
            title: Text("MR #${item['mrNo']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['item']['name']),
            trailing: Text("${item['receivedQty']} Bags", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../NetworkService/firebase_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isConnected = true;
  int _totalTasks = 0;
  int _pendingSync = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadDashboardData();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (mounted) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get data from database service
      _totalTasks = await _databaseService.getTaskCount();
      _pendingSync = await _databaseService.getPendingSyncCount();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseService.syncTasks();
      await _loadDashboardData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: const Color(0xFF1E3A8A), // Dark blue
        title: const Text(
          'Sales Task Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          // Connection status indicator in app bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Connected' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFFF5F7FF)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Dashboard Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildDashboardCard(
                        icon: Icons.assignment,
                        iconColor: const Color(0xFF1E3A8A),
                        backgroundColor: Colors.white,
                        title: 'Total Tasks',
                        value: _totalTasks.toString(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDashboardCard(
                        icon: Icons.sync,
                        iconColor: Colors.orange,
                        backgroundColor: Colors.white,
                        title: 'Pending Sync',
                        value: _pendingSync.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildActionButton(
                  title: 'New Task',
                  icon: Icons.add,
                  color: const Color(0xFF1E3A8A),
                  onPressed: () {
                    Navigator.pushNamed(context, '/new-task')
                        .then((_) => _loadDashboardData());
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: 'View All Tasks',
                  icon: Icons.list,
                  color: const Color(0xFF2E7D32),
                  onPressed: () {
                    Navigator.pushNamed(context, '/tasks')
                        .then((_) => _loadDashboardData());
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: 'Sync Now',
                  icon: Icons.sync,
                  color: const Color(0xFF546E7A),
                  onPressed: _syncNow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
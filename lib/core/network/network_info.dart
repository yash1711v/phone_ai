import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Network info service to check internet connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<ConnectivityResult> get connectivityStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  final Connectivity connectivity;

  NetworkInfoImpl({
    required this.connectionChecker,
    required this.connectivity,
  });

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;

  @override
  Stream<ConnectivityResult> get connectivityStream => 
      connectivity.onConnectivityChanged.map((results) => results.first);
}

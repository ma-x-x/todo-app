import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/network_service.dart';

class NetworkStatusIndicator extends StatelessWidget {
  const NetworkStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.read<NetworkService>().onConnectionChange,
      initialData: context.read<NetworkService>().hasConnection,
      builder: (context, snapshot) {
        final hasConnection = snapshot.data ?? true;
        if (hasConnection) return const SizedBox.shrink();

        return Container(
          color: Colors.red,
          padding: const EdgeInsets.all(8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '离线模式',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

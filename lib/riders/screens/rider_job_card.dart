import 'package:bokku_mart/riders/domain/entities/rider_job_entity.dart';
import 'package:flutter/material.dart';

class RiderJobCard extends StatelessWidget {
  final RiderJobEntity job;
  final VoidCallback onTap;

  const RiderJobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.orderReference,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusChip(status: job.status),
                ],
              ),
              const SizedBox(height: 8),
              _Row(icon: Icons.storefront_outlined, text: job.storeName),
              const SizedBox(height: 4),
              _Row(icon: Icons.person_outline, text: job.customerName),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isEmpty ? '—' : text,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case DeliveryStatus.pending:
      case DeliveryStatus.assigned:
        return Colors.blueGrey;
      case DeliveryStatus.accepted:
      case DeliveryStatus.pickedUp:
        return Colors.orange;
      case DeliveryStatus.outForDelivery:
        return Colors.blue;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.rejected:
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

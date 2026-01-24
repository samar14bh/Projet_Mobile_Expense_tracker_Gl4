import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isBalance;
  final double? income;
  final double? expense;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.isBalance = false,
    this.income,
    this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isBalance ? context.tokens.balanceGradient : null,
        color: isBalance ? null : context.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [context.tokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isBalance ? Colors.white.withOpacity(0.8) : context.textTheme.bodyMedium?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isBalance)
                const Icon(Icons.more_horiz, color: Colors.white)
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isBalance ? Colors.white : context.textTheme.titleLarge?.color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isBalance) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                _MiniIndicator(
                  label: 'Income',
                  amount: (income ?? 0.0).toStringAsFixed(2),
                  isUp: true,
                ),
                const SizedBox(width: 24),
                _MiniIndicator(
                  label: 'Expenses',
                  amount: (expense ?? 0.0).toStringAsFixed(2),
                  isUp: false,
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}

class _MiniIndicator extends StatelessWidget {
  final String label;
  final String amount;
  final bool isUp;

  const _MiniIndicator({required this.label, required this.amount, required this.isUp});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
            Text('\$$amount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }
}

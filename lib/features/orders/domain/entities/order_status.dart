/// Mirrors the `status` text values allowed in the `orders` table (see
/// `supabase/migrations/0002_orders_schema.sql`). Kept as an app-level
/// enum rather than a DB check constraint so new statuses don't need a
/// migration — see that file's closing comment.
enum OrderStatus {
  placed,
  confirmed,
  packed,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (OrderStatus s) => s.name == value,
      orElse: () => OrderStatus.placed,
    );
  }

  String get label => switch (this) {
        OrderStatus.placed => 'Order Placed',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.packed => 'Packed',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };
}

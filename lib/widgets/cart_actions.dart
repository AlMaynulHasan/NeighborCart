import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

/// Adds one unit of [product] to the member's active-pool cart and tells
/// them what happened (shared by Home and the All Products screen).
Future<void> addProductToCart(BuildContext context, ProductModel product) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await CartService.instance.addToActivePool(product);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.name} added to your cart'),
        duration: const Duration(seconds: 1),
      ),
    );
  } on NoActivePoolException {
    messenger.showSnackBar(
      const SnackBar(content: Text('Join a pool first to start shopping.')),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not add item. Please try again.')),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

/// Adds one unit of [product] to the member's active-pool cart and tells
/// them what happened (shared by Home and the All Products screen).
Future<void> addProductToCart(BuildContext context, ProductModel product, {int quantity = 1}) async {
  final messenger = ScaffoldMessenger.of(context);
  void say(String text) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
  }

  try {
    await CartService.instance.addToActivePool(product, quantity: quantity);
    say(quantity == 1 ? '${product.name} added to your cart' : '$quantity x ${product.name} added to your cart');
  } on NoActivePoolException {
    say('Join a pool first to start shopping.');
  } on PoolClosedException {
    say('Ordering is closed for this pool.');
  } on AlreadyPaidException {
    say('You have already paid for this order.');
  } catch (_) {
    say('Could not add item. Please try again.');
  }
}

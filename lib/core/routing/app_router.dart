import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/about/about_screen.dart';
import '../../features/admin/admin_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_success_screen.dart';
import '../../features/contact/contact_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/pairings/pairings_screen.dart';
import '../../features/product_details/product_details_screen.dart';
import '../../features/shop/shop_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: '/product/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return ProductDetailsScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/pairings',
      builder: (context, state) => const PairingsScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/order-success/:orderNumber',
      builder: (context, state) {
        final orderNumber = state.pathParameters['orderNumber'] ?? '';
        return OrderSuccessScreen(orderNumber: orderNumber);
      },
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Page Not Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('RETURN TO STORE'),
          ),
        ],
      ),
    ),
  ),
);

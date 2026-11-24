import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/batch.dart';
import '../models/order.dart';
import 'delivery_rules.dart';
import 'mock_data.dart';

const kUseFirestore = true;

class AppState extends ChangeNotifier {
  final List<StreamSubscription> _subs = [];
  bool _rulesLoaded = false;
  bool get rulesLoaded => _rulesLoaded;

  List<Batch> get batches => MockData.batches;
  List<PineappleOrder> get orders => MockData.orders;
  List<String> get deliverySlots => MockData.deliverySlots;

  void init({bool useFirestore = kUseFirestore}) {
    if (!useFirestore) return;
    _connectFirestore();
  }

  void _connectFirestore() {
    final db = FirebaseFirestore.instance;

    _subs.add(db.collection('batches').snapshots().listen((snap) {
      MockData.batches = snap.docs
          .map((d) => Batch.fromMap(d.id, d.data()))
          .toList();
      notifyListeners();
    }));

    _subs.add(db.collection('orders')
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .listen((snap) {
      MockData.orders = snap.docs
          .map((d) => PineappleOrder.fromMap(d.id, d.data()))
          .toList();
      notifyListeners();
    }));

    _subs.add(db.doc('config/deliverySlots').snapshots().listen((snap) {
      if (snap.exists) {
        final raw = snap.data()?['slots'];
        if (raw is List) {
          MockData.deliverySlots = List<String>.from(raw);
          notifyListeners();
        }
      }
    }));

    _subs.add(db.doc('config/deliveryRules').snapshots().listen((snap) {
      if (snap.exists) {
        final d = snap.data()!;
        if (d['radiusKm'] is num) DeliveryRules.radiusKm = (d['radiusKm'] as num).toDouble();
        if (d['ratePerKm'] is num) DeliveryRules.ratePerKm = (d['ratePerKm'] as num).toDouble();
        if (d['minOrderKg'] is num) DeliveryRules.minOrderKg = (d['minOrderKg'] as num).toDouble();
        if (d['vendorLat'] is num) DeliveryRules.vendorLat = (d['vendorLat'] as num).toDouble();
        if (d['vendorLng'] is num) DeliveryRules.vendorLng = (d['vendorLng'] as num).toDouble();
        _rulesLoaded = true;
        notifyListeners();
      }
    }));

    _seedFirestoreIfEmpty();
  }

  Future<void> _seedFirestoreIfEmpty() async {
    final db = FirebaseFirestore.instance;
    final snap = await db.collection('batches').limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final batch = db.batch();
    for (final b in MockData.batches) {
      batch.set(db.collection('batches').doc(b.id), b.toMap());
    }
    for (final o in MockData.orders) {
      batch.set(db.collection('orders').doc(o.id), o.toMap());
    }
    batch.set(
      db.doc('config/deliverySlots'),
      {'slots': MockData.deliverySlots},
    );
    await batch.commit();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  // ── Order mutations ────────────────────────────────────────────────────────

  void updateOrderStatus(String orderId, String newStatus) {
    final i = MockData.orders.indexWhere((o) => o.id == orderId);
    if (i == -1) return;
    MockData.orders[i] = MockData.orders[i].copyWith(status: newStatus);
    notifyListeners();
    FirebaseFirestore.instance
        .doc('orders/$orderId')
        .update({'status': newStatus});
  }

  void placeOrder(PineappleOrder order) {
    MockData.orders.add(order);
    final bi = MockData.batches.indexWhere((b) => b.id == order.batchId);
    if (bi != -1) {
      MockData.batches[bi] = MockData.batches[bi].copyWith(
        stockKg: MockData.batches[bi].stockKg - order.quantityKg,
      );
    }
    notifyListeners();
    final db = FirebaseFirestore.instance;
    db.collection('orders').doc(order.id).set(order.toMap());
    if (bi != -1) {
      db.doc('batches/${order.batchId}')
          .update({'stockKg': MockData.batches[bi].stockKg});
    }
  }

  // ── Batch mutations ────────────────────────────────────────────────────────

  void updateBatch(int index,
      {double? pricePerKg, double? stockKg, String? status}) {
    MockData.batches[index] = MockData.batches[index].copyWith(
      pricePerKg: pricePerKg,
      stockKg: stockKg,
      status: status,
    );
    notifyListeners();
    final b = MockData.batches[index];
    FirebaseFirestore.instance.doc('batches/${b.id}').update(b.toMap());
  }

  void addBatch(Batch batch) {
    MockData.batches.add(batch);
    notifyListeners();
    FirebaseFirestore.instance
        .collection('batches')
        .doc(batch.id)
        .set(batch.toMap());
  }

  // ── Slot mutations ─────────────────────────────────────────────────────────

  void addSlot(String slot) {
    MockData.deliverySlots.add(slot);
    notifyListeners();
    FirebaseFirestore.instance
        .doc('config/deliverySlots')
        .set({'slots': List<String>.from(MockData.deliverySlots)});
  }

  void removeSlot(int index) {
    MockData.deliverySlots.removeAt(index);
    notifyListeners();
    FirebaseFirestore.instance
        .doc('config/deliverySlots')
        .set({'slots': List<String>.from(MockData.deliverySlots)});
  }

  // ── Delivery-rule mutations ────────────────────────────────────────────────

  void saveDeliveryRules({
    double? radiusKm,
    double? ratePerKm,
    double? minOrderKg,
    double? vendorLat,
    double? vendorLng,
  }) {
    if (radiusKm != null) DeliveryRules.radiusKm = radiusKm;
    if (ratePerKm != null) DeliveryRules.ratePerKm = ratePerKm;
    if (minOrderKg != null) DeliveryRules.minOrderKg = minOrderKg;
    if (vendorLat != null) DeliveryRules.vendorLat = vendorLat;
    if (vendorLng != null) DeliveryRules.vendorLng = vendorLng;
    notifyListeners();
    FirebaseFirestore.instance.doc('config/deliveryRules').set({
      'radiusKm': DeliveryRules.radiusKm,
      'ratePerKm': DeliveryRules.ratePerKm,
      'minOrderKg': DeliveryRules.minOrderKg,
      'vendorLat': DeliveryRules.vendorLat,
      'vendorLng': DeliveryRules.vendorLng,
    });
  }
}

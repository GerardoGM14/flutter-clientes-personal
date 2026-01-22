import 'package:flutter/material.dart';

class Trabajo {
  final String cliente;
  final String descripcion;
  final DateTime fechaEntrega;
  final double pago;
  final Color colorTarjeta;

  Trabajo({
    required this.cliente,
    required this.descripcion,
    required this.fechaEntrega,
    required this.pago,
    required this.colorTarjeta,
  });
}

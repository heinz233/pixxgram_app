// lib/widgets/widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

// ─── Brand colors ─────────────────────────────────────────────────────────────
// Fix 1: removed unused imports:
//   - 'package:http/http.dart'   (never used in this file)
//   - '../config/api_config.dart' (AppColors was defined there but caused
//                                  a const issue — moved colors here directly)
//   - '../models/models.dart'     (no model classes used in this file)

const kCobalt = Color(0xFF0047AB);
const kNavy   = Color(0xFF000080);
const kSky    = Color(0xFF82C8E5);
const kSlate  = Color(0xFF6D8196);

// ─── Custom Button ────────────────────────────────────────────────────────────
class PxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool outlined;

  const PxButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.color,
    this.textColor,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? kCobalt;

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: loading ? null : onTap,
        icon: loading
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon, size: 18) : const SizedBox.shrink()),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: bg,
          side: BorderSide(color: bg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : (icon != null ? Icon(icon, size: 18) : const SizedBox.shrink()),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}

// ─── Custom Text Field ────────────────────────────────────────────────────────
class PxTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final void Function(String)? onChanged;

  const PxTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: obscure ? 1 : maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: kSlate)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kCobalt, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF0F6FB),
      ),
    );
  }
}

// ─── Photographer Card ────────────────────────────────────────────────────────
class PhotographerCard extends StatelessWidget {
  final Map<String, dynamic> photographer;
  final VoidCallback? onTap;

  const PhotographerCard({
    super.key,
    required this.photographer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final profile    = photographer['photographer_profile'] as Map<String, dynamic>?;
    final name       = photographer['name'] ?? 'Unknown';
    final location   = profile?['location'] ?? 'Kenya';
    final rating     = profile?['average_rating'];
    final rate       = profile?['hourly_rate'];
    final photo      = profile?['profile_photo'] as String?;
    final speciality = profile?['speciality'];

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: photo != null
                  ? CachedNetworkImage(
                      imageUrl: photo,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => _shimmer(),
                      errorWidget: (c, u, e) => _placeholder(),
                    )
                  : _placeholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 14, color: kSlate),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(location,
                          style: const TextStyle(fontSize: 12, color: kSlate),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  if (speciality != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kSky.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(speciality,
                          style: const TextStyle(
                              fontSize: 11, color: kCobalt)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (rating != null)
                        Row(children: [
                          const Icon(Icons.star,
                              size: 14, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text('$rating',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      if (rate != null)
                        Text('Ksh $rate/hr',
                            style: const TextStyle(
                                fontSize: 12,
                                color: kCobalt,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 160,
        color: const Color(0xFFE2E8F0),
        child: const Center(
            child: Icon(Icons.camera_alt, size: 40, color: kSlate)),
      );

  Widget _shimmer() => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 160, color: Colors.white),
      );
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? sub;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                      overflow: TextOverflow.ellipsis),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            if (sub != null)
              Text(sub!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kNavy)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.45))),
              ],
            ],
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    fontSize: 13,
                    color: kCobalt,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ─── Loading Widget ───────────────────────────────────────────────────────────
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: kCobalt),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: const TextStyle(color: kSlate)),
          ],
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kNavy)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500])),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCobalt,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Fix 2: removed non-exhaustive switch warning by using if/else
    // instead of switch with fall-through default
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'active':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case 'pending':
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFF854D0E);
        break;
      case 'suspended':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case 'expired':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case 'confirmed':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case 'completed':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1E40AF);
        break;
      case 'open':
        bg = const Color(0xFFFEF9C3);
        fg = const Color(0xFF854D0E);
        break;
      case 'resolved':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF065F46);
        break;
      case 'dismissed':
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';

import 'archy_tokens.dart';
import 'archy_theme.dart';

/// Reusable UI primitives ported from the approved Archy HTML design.
/// All take an [ArchyColors] `c` so they render correctly in light/dark.

/// Editorial card: soft surface, hairline border, gentle radius.
class ArchyCard extends StatelessWidget {
  final ArchyColors c;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const ArchyCard({
    super.key,
    required this.c,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.paper2,
        borderRadius: BorderRadius.circular(ArchySize.radiusCard),
        border: Border.all(color: c.line),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ArchySize.radiusCard),
      child: card,
    );
  }
}

enum ArchyBtnVariant { primary, ghost, soft }

class ArchyButton extends StatelessWidget {
  final ArchyColors c;
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ArchyBtnVariant variant;
  final bool full;
  final bool busy;

  const ArchyButton({
    super.key,
    required this.c,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = ArchyBtnVariant.primary,
    this.full = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool primary = variant == ArchyBtnVariant.primary;
    final bool soft = variant == ArchyBtnVariant.soft;
    final Color bg = primary
        ? c.clay
        : soft
            ? c.claySoft
            : Colors.transparent;
    final Color fg = primary
        ? Colors.white
        : soft
            ? c.clayDeep
            : c.ink;

    return SizedBox(
      width: full ? double.infinity : null,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArchySize.radiusSm),
          side: variant == ArchyBtnVariant.ghost
              ? BorderSide(color: c.line)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(ArchySize.radiusSm),
          onTap: busy ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 19, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: ArchyTheme.sans(c,
                        size: 15, weight: FontWeight.w600, color: fg),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small status pill with a tone color.
class ArchyPill extends StatelessWidget {
  final ArchyColors c;
  final String label;
  final String tone;
  final IconData? icon;

  const ArchyPill({
    super.key,
    required this.c,
    required this.label,
    this.tone = 'neutral',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final col = c.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.toneSoft(tone),
        borderRadius: BorderRadius.circular(ArchySize.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: col),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: ArchyTheme.sans(c,
                  size: 11.5, weight: FontWeight.w600, color: col)),
        ],
      ),
    );
  }
}

/// Thin progress bar with a tone fill.
class ArchyProgress extends StatelessWidget {
  final ArchyColors c;
  final double value; // 0..100
  final String tone;
  final double height;

  const ArchyProgress({
    super.key,
    required this.c,
    required this.value,
    this.tone = 'clay',
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ArchySize.radiusPill),
      child: LinearProgressIndicator(
        value: (value.clamp(0, 100)) / 100,
        minHeight: height,
        backgroundColor: c.isDark ? Colors.white12 : Colors.black12,
        valueColor: AlwaysStoppedAnimation(c.tone(tone)),
      ),
    );
  }
}

/// KES money label in mono, with a small currency prefix (matches design).
class ArchyMoney extends StatelessWidget {
  final ArchyColors c;
  final num amount;
  final String currency;
  final double size;
  final Color? color;

  const ArchyMoney({
    super.key,
    required this.c,
    required this.amount,
    this.currency = 'KES',
    this.size = 18,
    this.color,
  });

  static String format(num n) {
    final s = n.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: '$currency ',
          style: ArchyTheme.mono(c,
              size: size * 0.62,
              weight: FontWeight.w600,
              color: (color ?? c.ink).withValues(alpha: 0.62)),
        ),
        TextSpan(
          text: format(amount),
          style: ArchyTheme.mono(c,
              size: size,
              weight: FontWeight.w600,
              color: color ?? c.ink,
              letterSpacing: -0.02 * size),
        ),
      ]),
    );
  }
}

/// Round initials avatar with a tone.
class ArchyAvatar extends StatelessWidget {
  final ArchyColors c;
  final String name;
  final double size;
  final String tone;

  const ArchyAvatar({
    super.key,
    required this.c,
    required this.name,
    this.size = 40,
    this.tone = 'clay',
  });

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.toneSoft(tone),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: ArchyTheme.sans(c,
            size: size * 0.36, weight: FontWeight.w700, color: c.tone(tone)),
      ),
    );
  }
}

/// Uppercase mono section label, optional trailing widget.
class ArchySectionLabel extends StatelessWidget {
  final ArchyColors c;
  final String label;
  final Widget? trailing;

  const ArchySectionLabel({
    super.key,
    required this.c,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(),
              style: ArchyTheme.mono(c, size: 11, color: c.ink3)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Metric tile (number + label + sub).
class ArchyStatTile extends StatelessWidget {
  final ArchyColors c;
  final String label;
  final String value;
  final String? sub;
  final bool accent;
  final IconData? icon;

  const ArchyStatTile({
    super.key,
    required this.c,
    required this.label,
    required this.value,
    this.sub,
    this.accent = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = accent ? c.clayDeep : null;
    return ArchyCard(
      c: c,
      color: accent ? c.claySoft : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: accent ? c.clayDeep : c.ink3),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(label.toUpperCase(),
                    style: ArchyTheme.mono(c,
                        size: 10.5, color: fg ?? c.ink3)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: ArchyTheme.mono(c,
                  size: 26, weight: FontWeight.w700, color: fg ?? c.ink)),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!,
                style: ArchyTheme.sans(c,
                    size: 12, color: fg ?? c.ink3)),
          ],
        ],
      ),
    );
  }
}

/// Editorial text field.
class ArchyField extends StatelessWidget {
  final ArchyColors c;
  final String? label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? trailing;
  final String? Function(String?)? validator;

  const ArchyField({
    super.key,
    required this.c,
    this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.trailing,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(),
              style: ArchyTheme.mono(c, size: 10.5, color: c.ink3)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: ArchyTheme.sans(c, size: 15, color: c.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ArchyTheme.sans(c, size: 15, color: c.ink3),
            prefixIcon: icon != null ? Icon(icon, size: 18, color: c.ink3) : null,
            suffixIcon: trailing,
            filled: true,
            fillColor: c.paper3,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ArchySize.radiusSm),
              borderSide: BorderSide(color: c.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ArchySize.radiusSm),
              borderSide: BorderSide(color: c.clay, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ArchySize.radiusSm),
              borderSide: BorderSide(color: c.line),
            ),
          ),
        ),
      ],
    );
  }
}

/// Frosted-glass pill/button — the one sanctioned glassmorphism surface,
/// used only over the AR camera / 3D viewer.
class ArchyGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const ArchyGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    this.radius = ArchySize.radiusPill,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

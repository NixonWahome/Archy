import 'package:flutter/material.dart';
import 'app_theme.dart';

class NeomorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final bool isDarkMode;
  final bool isPressed;

  const NeomorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.isDarkMode = false,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    // Flattened to the Archy "editorial card": soft surface + hairline border,
    // no neumorphic double-shadows. (Class name kept so existing screens compile.)
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDarkMode ? AppTheme.darkShadow : AppTheme.lightShadow,
        ),
      ),
      child: child,
    );
  }
}

class NeomorphicButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool isDarkMode;
  final Color? color;

  const NeomorphicButton({
    super.key,
    this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.isDarkMode = false,
    this.color,
  });

  @override
  State<NeomorphicButton> createState() => _NeomorphicButtonState();
}

class _NeomorphicButtonState extends State<NeomorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Restyled as the Archy clay primary button (filled accent, white content).
    final bool disabled = widget.onPressed == null;
    final Color bg = widget.color ?? AppTheme.primaryBlue;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: disabled ? 0.5 : (_isPressed ? 0.85 : 1),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            child: IconTheme.merge(
              data: const IconThemeData(color: Colors.white, size: 19),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeomorphicIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final bool isDarkMode;
  final Color? iconColor;

  const NeomorphicIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.size = 50,
    this.isDarkMode = false,
    this.iconColor,
  });

  @override
  State<NeomorphicIconButton> createState() => _NeomorphicIconButtonState();
}

class _NeomorphicIconButtonState extends State<NeomorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: NeomorphicContainer(
        isDarkMode: widget.isDarkMode,
        isPressed: _isPressed,
        width: widget.size,
        height: widget.size,
        padding: EdgeInsets.zero,
        child: Center(
          child: Icon(
            widget.icon,
            color:
                widget.iconColor ??
                (widget.isDarkMode ? Colors.white : Colors.black87),
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}

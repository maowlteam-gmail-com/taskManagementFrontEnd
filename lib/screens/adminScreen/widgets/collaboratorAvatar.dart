import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollaboratorAvatar extends StatefulWidget {
  final String name;
  final double size;
  final Color? backgroundColor;

  const CollaboratorAvatar({
    super.key,
    required this.name,
    this.size = 36,
    this.backgroundColor,
  });

  @override
  State<CollaboratorAvatar> createState() => _CollaboratorAvatarState();
}

class _CollaboratorAvatarState extends State<CollaboratorAvatar> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(BuildContext context) {
    _removeOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 40,
        top: position.dy - 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4.sp),
            ),
            child: Text(
              widget.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Color _getAvatarColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final int hashCode = widget.name.hashCode;
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[hashCode.abs() % colors.length];
  }

  String _getInitials() {
    final List<String> nameParts = widget.name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        return MouseRegion(
          onEnter: (_) {
            setState(() => _isHovering = true);
            _showOverlay(ctx);
          },
          onExit: (_) {
            setState(() => _isHovering = false);
            _removeOverlay();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: widget.size.sp,
            height: widget.size.sp,
            decoration: BoxDecoration(
              color: _getAvatarColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isHovering ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: _isHovering
                  ? [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)]
                  : [],
            ),
            child: Center(
              child: Text(
                _getInitials(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: (widget.size / 2).sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.backgroundColor,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final initials = _getInitials();

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => _buildPlaceholder(bg, initials),
        errorWidget: (context, url, error) => _buildPlaceholder(bg, initials),
      );
    } else {
      avatar = _buildPlaceholder(bg, initials);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _buildPlaceholder(Color bg, String initials) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w600,
              ),
            )
          : Icon(Icons.person, size: radius * 1.2, color: Colors.white),
    );
  }

  String _getInitials() {
    if (name == null || name!.trim().isEmpty) return '';
    final parts = name!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

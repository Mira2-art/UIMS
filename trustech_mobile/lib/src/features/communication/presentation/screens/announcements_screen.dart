import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/communication_providers.dart';
import '../../data/mock/communication_mock.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  AnnouncementCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider).valueOrNull ?? const [];
    final cs = Theme.of(context).colorScheme;

    final filteredAnnouncements = _selectedCategory == null
        ? announcements
        : announcements.where((a) => a.category == _selectedCategory).toList();

    final featured = filteredAnnouncements.where((a) => a.isFeatured).firstOrNull ?? filteredAnnouncements.firstOrNull;
    final others = filteredAnnouncements.where((a) => a.id != featured?.id).toList();

    return Scaffold(
      appBar: AppHeaderBar.home(
        title: 'Trustech',
        avatarName: 'John Doe',
        onNotification: () => context.push('/notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'CAMPUS UPDATES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Announcements',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stay updated with the latest happenings, academic deadlines, and campus life events.',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Featured Announcement
            if (featured != null) ...[
              _FeaturedCard(
                announcement: featured,
                onTap: () => context.push('/announcements/${featured.id}'),
              ),
              const SizedBox(height: 24),
            ],

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All Items',
                    isSelected: _selectedCategory == null,
                    onSelected: () => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: 8),
                  ...AnnouncementCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: cat.label.split(' ').map((s) => s[0] + s.substring(1).toLowerCase()).join(' '),
                          isSelected: _selectedCategory == cat,
                          onSelected: () => setState(() => _selectedCategory = cat),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (filteredAnnouncements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: TrustechEmptyState(
                  title: 'No announcements yet',
                  message: 'New announcements will appear here when posted.',
                  icon: Icons.campaign_outlined,
                ),
              ),

            // Bento Grid (Manual implementation via Wrap or Column/Rows)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: others.length,
              itemBuilder: (context, index) {
                return _AnnouncementGridCard(
                  announcement: others[index],
                  onTap: () => context.push('/announcements/${others[index].id}'),
                );
              },
            ),

            if (others.isNotEmpty) ...[
            const SizedBox(height: 32),
            Center(
              child: TrustechButton(
                label: 'Load Older Announcements',
                variant: TrustechButtonVariant.outline,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.announcement, required this.onTap});
  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            if (announcement.imageUrl != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    announcement.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      cs.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'FEATURED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(announcement.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.excerpt,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onPrimary.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _AnnouncementGridCard extends StatelessWidget {
  const _AnnouncementGridCard({required this.announcement, required this.onTap});
  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TrustechCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(announcement.category, cs).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  announcement.category.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _getCategoryColor(announcement.category, cs),
                  ),
                ),
              ),
              Icon(Icons.more_vert, size: 16, color: cs.outline),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              announcement.excerpt,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 12, color: cs.primary),
              const SizedBox(width: 4),
              Text(
                _getTimeAgo(announcement.date),
                style: TextStyle(
                  fontSize: 10,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(AnnouncementCategory category, ColorScheme cs) {
    switch (category) {
      case AnnouncementCategory.academic:
        return cs.tertiary;
      case AnnouncementCategory.event:
        return cs.primary;
      case AnnouncementCategory.campusLife:
        return cs.secondary;
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

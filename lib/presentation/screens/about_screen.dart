import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About CazLync'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Image.asset(
                'assets/logo/cazlync_logo.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Center(
              child: Text(
                'CazLync Sales',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Tagline
            Center(
              child: Text(
                'Buy & Sell Cars in Zambia',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 32),
            
            // About Section
            _buildSection(
              context,
              'About Us',
              'We believe in the power of technology to transform the car buying and selling experience, and we\'re excited to be at the forefront of this innovation. Join us at Cazlync and discover a new way to buy and sell cars with convenience, transparency, and peace of mind.',
            ),
            
            const SizedBox(height: 24),
            
            // Contact Information
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            _buildContactCard(
              context,
              Icons.phone,
              'Phone',
              '(+260) 773521234',
              () => _launchPhone('+260773521234'),
            ),
            
            const SizedBox(height: 12),
            
            _buildContactCard(
              context,
              Icons.email,
              'Email',
              'admin@cazlync.com',
              () => _launchEmail('admin@cazlync.com'),
            ),
            
            const SizedBox(height: 12),
            
            _buildContactCard(
              context,
              Icons.location_on,
              'Location',
              'Lusaka, Zambia',
              null,
            ),
            
            const SizedBox(height: 32),
            
            // Quick Links
            Text(
              'Quick Links',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            _buildLinkItem(context, 'Listings', Icons.car_rental),
            _buildLinkItem(context, 'FAQ', Icons.help_outline),
            _buildLinkItem(context, 'Our Team', Icons.people_outline),
            _buildLinkItem(context, 'Blog', Icons.article_outlined),
            _buildLinkItem(context, 'Terms & Conditions', Icons.description_outlined),
            
            const SizedBox(height: 32),
            
            // Copyright
            Center(
              child: Text(
                '© 2023 by Mukanu Media. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: onTap != null
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 22,
      ),
      title: Text(title),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: () {
        // Navigate to respective screens or show info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title - Coming soon')),
        );
      },
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=CazLync Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

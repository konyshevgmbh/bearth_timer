import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Import business logic modules
import '../core/constants.dart';
import '../main.dart'; // For AppState access
import '../services/sync_service.dart';
import '../services/sound_service.dart';
import '../services/export_import_service.dart';
import '../generated/l10n/app_localizations.dart';
import 'auth_page.dart';
import 'delete_account_page.dart';

// =============================================================================
// SETTINGS PAGE
// =============================================================================

/// Settings page for account management, sync options, data import/export, and exercise configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  late Stream<SyncStatus> _syncStatusStream;
  StreamSubscription<SyncStatus>? _syncStatusSubscription;
  bool _soundEnabled = true;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _syncStatusStream = SyncService().syncStatusStream;
    _syncStatusSubscription = _syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {});
      }
    });
    _loadSoundSetting();
    _loadAppVersion();
  }

  Future<void> _loadSoundSetting() async {
    try {
      setState(() {
        _soundEnabled = SoundService().isSoundEnabled;
      });
    } catch (e) {
      debugPrint('Error loading sound setting: $e');
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
      });
    } catch (e) {
      debugPrint('Error loading app version: $e');
      setState(() {
        _version = '0.9.0'; // Fallback to pubspec version
      });
    }
  }

  @override
  void dispose() {
    _syncStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
 
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppLayout.maxScreenPadding),
          child: Column(
            children: [
              // Account Section
              _buildSection(
                title: AppLocalizations.of(context).account,
                icon: Icons.account_circle,
                children: [
                  if (isLoggedIn) ...[
                    _buildInfoTile(
                      icon: Icons.email,
                      title: AppLocalizations.of(context).signedInAs,
                      subtitle: user.email ?? AppLocalizations.of(context).unknownEmail,
                    ),
                    SizedBox(height: AppLayout.sectionSpacingSmall),
                    _buildActionTile(
                      icon: Icons.logout,
                      title: AppLocalizations.of(context).signOut,
                      subtitle: AppLocalizations.of(context).signOutDescription,
                      color: Theme.of(context).colorScheme.error,
                      onTap: _handleSignOut,
                    ),
                    SizedBox(height: AppLayout.sectionSpacingSmall),
                    _buildActionTile(
                      icon: Icons.delete_forever,
                      title: AppLocalizations.of(context).deleteAccount,
                      subtitle: AppLocalizations.of(context).deleteAccountDescription,
                      color: Theme.of(context).colorScheme.error,
                      onTap: _handleDeleteAccount,
                    ),
                  ] else ...[
                    _buildInfoTile(
                      icon: Icons.cloud_off,
                      title: AppLocalizations.of(context).workingOffline,
                      subtitle: AppLocalizations.of(context).signInToSync,
                    ),
                    SizedBox(height: AppLayout.sectionSpacingSmall),
                    _buildActionTile(
                      icon: Icons.login,
                      title: AppLocalizations.of(context).signIn,
                      subtitle: AppLocalizations.of(context).accessDataAnywhereButton,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: _handleSignIn,
                    ),
                  ],
                ],
              ),

              SizedBox(height: AppLayout.sectionSpacingLarge),


              // Sync Section
              if (isLoggedIn) ...[
                _buildSection(
                  title: AppLocalizations.of(context).sync,
                  icon: Icons.sync,
                  children: [
                    _buildActionTile(
                      icon: Icons.refresh,
                      title: AppLocalizations.of(context).retrySync,
                      subtitle: AppLocalizations.of(context).syncWithCloud,
                      onTap: _handleRetrySync,
                    ),
                  ],
                ),
                SizedBox(height: AppLayout.sectionSpacingLarge),
              ],

              // Sound Settings Section
              _buildSection(
                title: AppLocalizations.of(context).sound,
                icon: Icons.volume_up,
                children: [
                  _buildSoundToggle(),
                ],
              ),

              SizedBox(height: AppLayout.sectionSpacingLarge),

              // Data Management Section
              _buildSection(
                title: AppLocalizations.of(context).dataManagement,
                icon: Icons.storage,
                children: [
                  _buildActionTile(
                    icon: Icons.file_download,
                    title: AppLocalizations.of(context).exportData,
                    subtitle: AppLocalizations.of(context).saveDataToFile,
                    onTap: _handleExportData,
                  ),
                  SizedBox(height: AppLayout.sectionSpacingSmall),
                  _buildActionTile(
                    icon: Icons.file_upload,
                    title: AppLocalizations.of(context).importData,
                    subtitle: AppLocalizations.of(context).loadDataFromFile,
                    onTap: _handleImportData,
                  ),
                  SizedBox(height: AppLayout.sectionSpacingSmall),
                  _buildActionTile(
                    icon: Icons.delete_forever,
                    title: AppLocalizations.of(context).clearAllData,
                    subtitle: AppLocalizations.of(context).deleteAllDataPermanently,
                    color: Theme.of(context).colorScheme.error,
                    onTap: _handleClearAllData,
                  ),
                ],
              ),

              SizedBox(height: AppLayout.sectionSpacingLarge),

              // Appearance Section
              _buildSection(
                title: AppLocalizations.of(context).appearance,
                icon: Icons.palette,
                children: [
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context).darkMode),
                    subtitle: Text(AppLocalizations.of(context).useDarkTheme),
                    value: AppState().isDarkMode,
                    onChanged: (value) {
                      AppState().toggleTheme();
                    },
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppLayout.spacingSmall,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppLayout.sectionSpacingLarge),

              // About Section
              _buildSection(
                title: AppLocalizations.of(context).about,
                icon: Icons.info,
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/icon.png',
                      width: AppLayout.iconSizeMedium,
                      height: AppLayout.iconSizeMedium,
                    ),
                    title: Text(
                      AppLocalizations.of(context).appTitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: AppLayout.fontSizeSmall,
                      ),
                    ),
                    subtitle: Text(
                      _version.isEmpty ? AppLocalizations.of(context).loading : AppLocalizations.of(context).version(_version),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: AppLayout.fontSizeSmall,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppLayout.spacingSmall,
                      vertical: 4,
                    ),
                  ),
                  ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.spacingMedium,
            vertical: AppLayout.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: AppLayout.iconSizeSmall,
              ),
              SizedBox(width: AppLayout.spacingSmall),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: AppLayout.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.onSurface,
        size: AppLayout.iconSizeMedium,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onSurface,
          fontSize: AppLayout.fontSizeSmall,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: AppLayout.fontSizeSmall,
        ),
      ),
      onTap: _isLoading ? null : onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppLayout.buttonBorderRadius),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppLayout.spacingSmall,
        vertical: 4,
      ),
      trailing: _isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 16,
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: AppLayout.iconSizeMedium,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: AppLayout.fontSizeSmall,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: AppLayout.fontSizeSmall,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppLayout.spacingSmall,
        vertical: 4,
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final confirmed = await _showConfirmDialog(
      title: AppLocalizations.of(context).signOutConfirmTitle,
      message: AppLocalizations.of(context).signOutConfirmMessage,
      confirmText: AppLocalizations.of(context).signOut,
      isDestructive: false,
    );

    if (confirmed) {
      setState(() => _isLoading = true);
      try {
        await SyncService().signOut();
        // Force rebuild to update UI
        setState(() {});
      } catch (e) {
        // Failed to sign out
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignIn() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  Future<void> _handleDeleteAccount() async {
    // Navigate to delete account page with OTP verification
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeleteAccountPage(),
      ),
    );
  }



  Future<void> _handleRetrySync() async {
    setState(() => _isLoading = true);
    try {
      await SyncService().retrySync();
      // Sync completed
    } catch (e) {
      // Sync failed
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleExportData() async {
    setState(() => _isLoading = true);
    try {
      final success = await ExportImportService().exportToFile();
    } catch (e) {
      // Export failed
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleImportData() async {
    setState(() => _isLoading = true);
    try {
      final result = await ExportImportService().importAndApply();
      if (result.success) {
        // Data imported successfully
      } else {
        // Import failed
      }
    } catch (e) {
      // Import failed
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _handleClearAllData() async {
    final confirmed = await _showConfirmDialog(
      title: AppLocalizations.of(context).clearAllDataConfirmTitle,
      message: AppLocalizations.of(context).clearAllDataConfirmMessage,
      confirmText: AppLocalizations.of(context).clearAll,
      isDestructive: true,
    );

    if (confirmed) {
      setState(() => _isLoading = true);
      try {
        await SyncService().clearAllData();
        // All data cleared
      } catch (e) {
        // Failed to clear data
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isDestructive,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildSoundToggle() {
    return SwitchListTile(
      title: Text(
        AppLocalizations.of(context).transitionSound,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: AppLayout.fontSizeSmall,
        ),
      ),
      subtitle: Text(
        AppLocalizations.of(context).playSoundWhenPhasesChange,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: AppLayout.fontSizeSmall,
        ),
      ),
      value: _soundEnabled,
      onChanged: _handleSoundToggle,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppLayout.spacingSmall,
        vertical: 4,
      ),
    );
  }

  Future<void> _handleSoundToggle(bool value) async {
    try {
      setState(() {
        _soundEnabled = value;
      });
      
      // Update the sound service setting
      await SoundService().setSoundEnabled(value);
    } catch (e) {
      debugPrint('Error updating sound setting: $e');
      // Failed to update sound setting
    }
  }

}
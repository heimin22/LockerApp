import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Mock data for albums - in a real app this would come from storage
  final List<Album> _albums = [
    Album(
      name: 'Personal Photos',
      itemCount: 24,
      type: AlbumType.photos,
      thumbnail: 'assets/hamster.png',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Album(
      name: 'Videos',
      itemCount: 12,
      type: AlbumType.videos,
      thumbnail: 'assets/hamster.png',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Album(
      name: 'Documents',
      itemCount: 8,
      type: AlbumType.files,
      thumbnail: 'assets/otherfiles_icon.png',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddAlbumDialog,
            tooltip: 'Create Album',
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _albums.isEmpty ? _buildEmptyState() : _buildAlbumsGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImportOptions,
        tooltip: 'Import Files',
        child: const Icon(Icons.file_upload),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No albums yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first album to start hiding your files',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddAlbumDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Album'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          return _buildAlbumCard(_albums[index]);
        },
      ),
    );
  }

  Widget _buildAlbumCard(Album album) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openAlbum(album),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album thumbnail
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.backgroundLight,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Icon(
                          _getAlbumIcon(album.type),
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      // Item count badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${album.itemCount}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Album name
              Text(
                album.name,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Album info
              Text(
                _formatAlbumInfo(album),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAlbumIcon(AlbumType type) {
    switch (type) {
      case AlbumType.photos:
        return Icons.photo_library;
      case AlbumType.videos:
        return Icons.video_library;
      case AlbumType.files:
        return Icons.folder;
    }
  }

  String _formatAlbumInfo(Album album) {
    final daysDiff = DateTime.now().difference(album.createdAt).inDays;
    String timeAgo;
    
    if (daysDiff == 0) {
      timeAgo = 'Today';
    } else if (daysDiff == 1) {
      timeAgo = 'Yesterday';
    } else {
      timeAgo = '${daysDiff}d ago';
    }
    
    return '${album.itemCount} items • $timeAgo';
  }

  void _openAlbum(Album album) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${album.name}...')),
    );
    // TODO: Navigate to album detail screen
  }

  void _showAddAlbumDialog() {
    final TextEditingController nameController = TextEditingController();
    AlbumType selectedType = AlbumType.photos;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Album'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Album Name',
                hintText: 'Enter album name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AlbumType>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: 'Album Type',
              ),
              items: AlbumType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getAlbumIcon(type)),
                      const SizedBox(width: 8),
                      Text(_getAlbumTypeName(type)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (AlbumType? value) {
                if (value != null) {
                  selectedType = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                _createAlbum(nameController.text.trim(), selectedType);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  String _getAlbumTypeName(AlbumType type) {
    switch (type) {
      case AlbumType.photos:
        return 'Photos';
      case AlbumType.videos:
        return 'Videos';
      case AlbumType.files:
        return 'Files';
    }
  }

  void _createAlbum(String name, AlbumType type) {
    setState(() {
      _albums.add(Album(
        name: name,
        itemCount: 0,
        type: type,
        thumbnail: '',
        createdAt: DateTime.now(),
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Album "$name" created')),
    );
  }

  void _showImportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Import Photos'),
              onTap: () {
                Navigator.pop(context);
                _importFiles('photos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Import Videos'),
              onTap: () {
                Navigator.pop(context);
                _importFiles('videos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Import Files'),
              onTap: () {
                Navigator.pop(context);
                _importFiles('files');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _importFiles(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Importing $type...')),
    );
    // TODO: Implement file import functionality
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Data models
class Album {
  final String name;
  final int itemCount;
  final AlbumType type;
  final String thumbnail;
  final DateTime createdAt;

  Album({
    required this.name,
    required this.itemCount,
    required this.type,
    required this.thumbnail,
    required this.createdAt,
  });
}

enum AlbumType {
  photos,
  videos,
  files,
}
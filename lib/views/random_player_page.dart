import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../services/random_player_service.dart';
import '../services/shake_detector_service.dart';
import 'player_detail.dart';

class RandomPlayerPage extends StatefulWidget {
  const RandomPlayerPage({super.key});

  @override
  State<RandomPlayerPage> createState() => _RandomPlayerPageState();
}

class _RandomPlayerPageState extends State<RandomPlayerPage>
    with TickerProviderStateMixin {
  Player? _currentPlayer;
  bool _isLoading = false;
  bool _isShakeEnabled = true;
  bool _hasResult = false; // Track if we have a result

  late AnimationController _shakeAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;

  final ShakeDetector _shakeDetector = ShakeDetector();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startShakeDetection();
  }

  void _initializeAnimations() {
    // Shake animation for visual feedback
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _shakeAnimationController,
        curve: Curves.elasticIn,
      ),
    );

    // Fade animation for player card
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
  }

  void _startShakeDetection() {
    if (_isShakeEnabled && !_hasResult) {
      _shakeDetector.startListening(onShakeDetected: _onShakeDetected);
    }
  }

  void _stopShakeDetection() {
    _shakeDetector.stopListening();
  }

  void _onShakeDetected() {
    // Only respond to shake if we don't have a result and not currently loading
    if (!_isLoading && !_hasResult) {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Visual feedback
      _shakeAnimationController.forward().then((_) {
        _shakeAnimationController.reverse();
      });

      // Get new random player
      _getRandomPlayer();
    }
  }

  Future<void> _getRandomPlayer() async {
    setState(() {
      _isLoading = true;
    });

    // Stop shake detection while loading
    _stopShakeDetection();

    // Fade out current player if exists
    if (_currentPlayer != null) {
      await _fadeAnimationController.reverse();
    }

    try {
      final player = await RandomPlayerService.getRandomPlayer();
      if (mounted) {
        setState(() {
          _currentPlayer = player;
          _isLoading = false;
          _hasResult = player != null; // Set result status
        });

        if (player != null) {
          _fadeAnimationController.forward();
          // Don't restart shake detection here - user needs to manually shake again
        } else {
          _showErrorSnackBar('No player found. Try again!');
          // Restart shake detection if no result found
          _startShakeDetection();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load random player');
        // Restart shake detection on error
        _startShakeDetection();
      }
    }
  }

  void _resetSearch() {
    setState(() {
      _currentPlayer = null;
      _hasResult = false;
    });
    _fadeAnimationController.reset();
    // Restart shake detection after reset
    _startShakeDetection();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleShakeDetection() {
    setState(() {
      _isShakeEnabled = !_isShakeEnabled;
    });

    if (_isShakeEnabled) {
      // Only start listening if we don't have a result
      if (!_hasResult) {
        _shakeDetector.startListening(onShakeDetected: _onShakeDetected);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shake detection enabled'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _shakeDetector.stopListening();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shake detection disabled'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _shakeDetector.dispose();
    _shakeAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Random Player',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isShakeEnabled ? Icons.vibration : Icons.vibration_outlined,
              color: _isShakeEnabled ? Colors.green : Colors.grey,
            ),
            onPressed: _toggleShakeDetection,
            tooltip: _isShakeEnabled
                ? 'Disable Shake Detection'
                : 'Enable Shake Detection',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Instructions Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.1),
                            Theme.of(context).primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getInstructionIcon(),
                            size: 32,
                            color: _getInstructionColor(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getInstructionTitle(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getInstructionColor(),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getInstructionSubtitle(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loading or Player Card
                  if (_isLoading)
                    Container(
                      height: 400,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Finding a random player...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_currentPlayer != null)
                    Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildPlayerCard(_currentPlayer!),
                        ),
                        const SizedBox(height: 16),
                        // Reset button when we have a result
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _resetSearch,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Search Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 400,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getEmptyStateMessage(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!_isShakeEnabled) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Enable shake detection above to use shake gesture',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // Manual button only shown when no result or shake disabled
                  if (!_hasResult) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getRandomPlayer,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Get Random Player'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Status Text
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper methods for dynamic UI content
  IconData _getInstructionIcon() {
    if (!_isShakeEnabled) return Icons.phone_android_outlined;
    if (_hasResult) return Icons.check_circle;
    return Icons.phone_android;
  }

  Color _getInstructionColor() {
    if (!_isShakeEnabled) return Colors.grey;
    if (_hasResult) return Colors.green;
    return Theme.of(context).primaryColor;
  }

  String _getInstructionTitle() {
    if (!_isShakeEnabled) return 'Shake Detection Disabled';
    if (_hasResult) return 'Player Found!';
    return 'Shake Detection Active!';
  }

  String _getInstructionSubtitle() {
    if (!_isShakeEnabled)
      return 'Enable shake detection or use the button below';
    if (_hasResult)
      return 'Shake again to find another player or tap "Search Again"';
    return 'Shake your device to discover random football players';
  }

  String _getEmptyStateMessage() {
    if (!_isShakeEnabled) return 'Tap the button below to start!';
    return 'Shake your device to start!';
  }

  String _getStatusText() {
    if (!_isShakeEnabled) return 'Shake detection is disabled';
    if (_hasResult) return 'Shake again to search for another player';
    return 'Shake detection is active - waiting for shake...';
  }

  Color _getStatusColor() {
    if (!_isShakeEnabled) return Colors.grey;
    if (_hasResult) return Colors.orange;
    return Colors.green;
  }

  Widget _buildPlayerCard(Player player) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayerDetailPage(player: player)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Player Photo
              Hero(
                tag: 'player-${player.id}-random',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: Image.network(
                      player.photo,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Player Name
              Text(
                player.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Player Position
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  player.position,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickInfo(Icons.flag, 'Country', player.nationality),
                  _buildQuickInfo(Icons.cake, 'Age', '${player.age} years'),
                ],
              ),

              const SizedBox(height: 16),

              // Market Value
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Market Value',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      player.getFormattedMarketValue('USD'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tap to view details
              Text(
                'Tap to view full details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

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
    if (_isShakeEnabled) {
      _shakeDetector.startListening(onShakeDetected: _onShakeDetected);
    }
  }

  void _onShakeDetected() {
    if (!_isLoading) {
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

  Future<void> _getInitialRandomPlayer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final player = await RandomPlayerService.getRandomPlayer();
      if (mounted) {
        setState(() {
          _currentPlayer = player;
          _isLoading = false;
        });

        if (player != null) {
          _fadeAnimationController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load random player');
      }
    }
  }

  Future<void> _getRandomPlayer() async {
    setState(() {
      _isLoading = true;
    });

    // Fade out current player
    await _fadeAnimationController.reverse();

    try {
      final player = await RandomPlayerService.getRandomPlayer();
      if (mounted) {
        setState(() {
          _currentPlayer = player;
          _isLoading = false;
        });

        if (player != null) {
          _fadeAnimationController.forward();
        } else {
          _showErrorSnackBar('No player found. Try again!');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load random player');
      }
    }
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
      _shakeDetector.startListening(onShakeDetected: _onShakeDetected);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shake detection enabled - shake your device to get a player'),
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
            tooltip: _isShakeEnabled ? 'Disable Shake' : 'Enable Shake',
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
                            Icons.phone_android,
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shake Your Phone!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Shake your device or tap the button below to discover random football players',
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
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPlayerCard(_currentPlayer!),
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
                              'Shake your device to start!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Manual Refresh Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getRandomPlayer,
                      icon: const Icon(Icons.refresh),
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
              ),
            ),
          );
        },
      ),
    );
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

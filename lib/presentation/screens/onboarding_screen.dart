import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/route_names.dart';
import 'main_screen.dart'; // fallback if navigation replacement is tricky
import 'lock_screen.dart'; // if needed, but we likely nav to keys
import '../../presentation/widgets/secure_app_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Manage Finances',
      description: 'Track your expenses and income with ease. Keep your financial life organized.',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF6C63FF),
    ),
    OnboardingSlide(
      title: 'Detailed Insights',
      description: 'Visualize your spending habits with intuitive charts and reports.',
      icon: Icons.insert_chart_rounded,
      color: Colors.orange,
    ),
    OnboardingSlide(
      title: 'Secure & Private',
      description: 'Your data stays on your device. Secure it with PIN or Biometrics.',
      icon: Icons.shield_rounded,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: slide.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon, size: 80, color: slide.color),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Indicators and Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? theme.primaryColor 
                              : theme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  
                  // Buttons
                  Row(
                    children: [
                      // Skip Button
                      if (_currentPage < _slides.length - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text('Skip'),
                        )
                      else
                        const SizedBox(width: 64), // Spacer to balance layout
                        
                      const Spacer(),
                      
                      // Next / Get Started Button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _completeOnboarding();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(_currentPage == _slides.length - 1 ? 'Get Started' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      // Directly navigate to the Real Home (SecureAppWrapper)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SecureAppWrapper()),
      );
    }
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

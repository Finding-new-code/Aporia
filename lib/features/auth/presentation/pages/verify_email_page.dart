import 'package:flutter/material.dart';
import 'package:aporia/core/theme/app_theme.dart';
import 'package:aporia/features/auth/presentation/dataflows/auth_dataflow.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? initialToken;

  const VerifyEmailPage({super.key, this.initialToken});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late final TextEditingController _tokenController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
    
    // Auto-verify if token is provided via deep link
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      setState(() => _errorMessage = 'Please enter your verification code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthDataflow.verifyEmail(token);

      if (mounted) {
        setState(() {
          _success = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLightGray.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/space.jpg'),
            fit: BoxFit.cover,
            opacity: 0.4,
            isAntiAlias: true,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 96, height: 96),
              const SizedBox(height: 24),
              Text(
                'Verify your email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              if (_success)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Email verified successfully! You can now access all features.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                       ElevatedButton(
                        onPressed: () {
                           Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Back to Home'),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  'Enter the verification code sent to your email address.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textWhite,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _tokenController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppTheme.textGray),
                    labelText: 'Verification Code',
                    labelStyle: TextStyle(
                      color: AppTheme.textGray.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppTheme.surfaceLightGray),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    visualDensity: VisualDensity.comfortable,
                  ),
                ),
                
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textWhite,
                    foregroundColor: AppTheme.backgroundBlack,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppTheme.backgroundBlack,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify Email',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

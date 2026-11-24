import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/buyer_profile.dart';
import '../../services/fcm_service.dart';
import '../../theme.dart';
import 'home_screen.dart';

class BuyerProfileScreen extends StatefulWidget {
  final bool isEditing;
  const BuyerProfileScreen({super.key, this.isEditing = false});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final p = await BuyerProfile.load();
    if (p != null && mounted) {
      _nameCtrl.text = p.name;
      _phoneCtrl.text = p.phone;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await BuyerProfile.save(_nameCtrl.text, _phoneCtrl.text);
    FcmService.init(_phoneCtrl.text.trim()); // fire-and-forget: saves FCM token
    if (!mounted) return;
    setState(() => _saving = false);

    if (widget.isEditing) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: widget.isEditing
          ? AppBar(
              title: const Text('Edit profile'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isEditing) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('🍍', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Welcome to FreshPine',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16281F))),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Fresh pineapples delivered to your door',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ),
                  const SizedBox(height: 40),
                ],
                const Text('Your name',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A7060))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('e.g. Moncy Simon'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),
                const Text('Phone number',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A7060))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  decoration: _inputDecoration('10-digit mobile number'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your phone number';
                    if (v.length != 10) return 'Enter a valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            widget.isEditing ? 'Save changes' : 'Get started',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE4DFD2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE4DFD2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB23A2E)),
        ),
        counterText: '',
      );
}

import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget {
  final String error;
  final String url;
  final ValueChanged<String> onUrlSubmitted;

  const ErrorScreen({
    super.key,
    required this.error,
    required this.url,
    required this.onUrlSubmitted,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  late TextEditingController _controller;
  bool _showSettings = false;

  void _submit() {
    final text = _controller.text.trim();
    final uri = Uri.tryParse(text);
    final valid = text.isNotEmpty && uri != null && uri.isAbsolute &&
      (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    if (valid) {
      widget.onUrlSubmitted(text);
    }
  }

  void _retry() {
    widget.onUrlSubmitted('https://app.rinosat.com/painel');
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 96, color: Colors.blue),
              const SizedBox(height: 32),
              Text(
                'Falha na Conexão',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _retry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('TENTAR NOVAMENTE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (_showSettings) ...[
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'URL do Servidor',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _submit,
                      icon: const Icon(Icons.check),
                    ),
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _submit(),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _showSettings = !_showSettings),
                child: Text(_showSettings ? 'Ocultar Definições' : 'Configurar Servidor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

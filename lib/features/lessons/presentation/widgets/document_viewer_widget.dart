import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewerWidget extends StatefulWidget {
  const DocumentViewerWidget({super.key, required this.url});

  final String url;

  @override
  State<DocumentViewerWidget> createState() => _DocumentViewerWidgetState();
}

class _DocumentViewerWidgetState extends State<DocumentViewerWidget> {
  PdfControllerPinch? _controller;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final isPdf = widget.url.toLowerCase().contains('.pdf');
    if (!isPdf) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

      _controller = PdfControllerPinch(
        document: PdfDocument.openData(response.bodyBytes),
      );

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPdf = widget.url.toLowerCase().contains('.pdf');

    if (!isPdf) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Document uploaded'),
          subtitle: const Text('Open in browser or external app'),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openExternal,
          ),
        ),
      );
    }

    if (_loading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error || _controller == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Could not preview PDF in app'),
              TextButton.icon(
                onPressed: _openExternal,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in browser'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 500,
          child: PdfViewPinch(controller: _controller!),
        ),
        TextButton.icon(
          onPressed: _openExternal,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Open in browser'),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();

  String qrData = '';
  String selectedType = 'text';

  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'url': TextEditingController(),
  };

  String _generateQRData() {
    switch (selectedType) {
      case 'contact':
        return '''
BEGIN:VCARD
VERSION:3.0
FN:${_controllers['name']?.text}
TEL:${_controllers['phone']?.text}
EMAIL:${_controllers['email']?.text}
END:VCARD''';

      case 'url':
        String url = _controllers['url']?.text ?? '';
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        return url;

      default:
        return _textController.text;
    }
  }

  Future<void> _shareQRCode() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/qr_code.png';
    final capture = await _screenshotController.capture();
    if (capture == null) return;

    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(capture);
    await Share.shareXFiles([XFile(imagePath)], text: "Share QR Code");
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (_) {
          setState(() {
            qrData = _generateQRData();
          });
        },
      ),
    );
  }

  Widget _buildInputFields() {
    switch (selectedType) {
      case 'contact':
        return Column(
          children: [
            _buildTextField(_controllers['name']!, "Name"),
            _buildTextField(_controllers['phone']!, "Phone"),
            _buildTextField(_controllers['email']!, "Email"),
          ],
        );
      case 'url':
        return _buildTextField(_controllers['url']!, "URL");
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Enter Text',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                qrData = value;
              });
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Generate QR Code",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        selected: {selectedType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            selectedType = selection.first;
                            qrData = '';
                          });
                        },
                        segments: const [
                          ButtonSegment(
                            value: 'text',
                            label: Text("Text"),
                            icon: Icon(Icons.text_fields),
                          ),
                          ButtonSegment(
                            value: 'url',
                            label: Text("URL"),
                            icon: Icon(Icons.link),
                          ),
                          ButtonSegment(
                            value: 'contact',
                            label: Text("Contact"),
                            icon: Icon(Icons.contact_page),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildInputFields(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              if(qrData.isNotEmpty)
              Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape:RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:Padding(padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            color:Colors.white,
                            padding: EdgeInsets.all(16),
                            child:QrImageView(data: qrData,
                            version:QrVersions.auto,
                            size:200,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            )
                          ),
                        )
                      ],

                    )
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _shareQRCode,
                    icon: Icon(Icons.share), 
                    label: Text("Share QR Code"),
                    style:ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape:RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    )
                ],
              )



            ],
          ),
        ),
      ),
    );
  }
}

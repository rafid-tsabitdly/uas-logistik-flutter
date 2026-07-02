import 'dart:typed_data'; // Tambahan untuk format bytes PDF
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_page.dart';
import '../service/api_service.dart';
import '../model/product.dart';
import 'list_product.dart';
import 'map_page.dart';

// Import paket PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalItems = 0;
  int _totalStock = 0;
  double _totalAssetValue = 0.0;
  bool _isLoadingAnalytics = true;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    if (!mounted) return;
    setState(() => _isLoadingAnalytics = true);

    try {
      final List<Product> products = await ApiService.getProducts();
      int itemsCount = products.length;
      int stockCount = 0;
      double assetSum = 0.0;

      for (var product in products) {
        stockCount += product.stock;
        assetSum += (product.price * product.stock);
      }

      if (mounted) {
        setState(() {
          _totalItems = itemsCount;
          _totalStock = stockCount;
          _totalAssetValue = assetSum;
          _isLoadingAnalytics = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAnalytics = false);
    }
  }

  String _formatRupiah(double value) {
    String str = value.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.' + result;
      }
    }
    return 'Rp $result';
  }

  // LOGIKA PENYUSUNAN PDF (Web-Safe Version: Download Langsung)
  Future<void> _generatePdfReport() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final pdf = pw.Document();
      final products = await ApiService.getProducts();
      final dateStr =
          "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Laporan Inventaris Logistik IT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                'Dicetak pada: $dateStr',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Dilaporkan oleh: Muhammad Rafid Tsabitdly (NIM: 241011701060)',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Ringkasan Aset:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Total Komponen: $_totalItems Item | Total Stok: $_totalStock Unit',
              ),
              pw.Text(
                'Estimasi Nilai Aset: ${_formatRupiah(_totalAssetValue)}',
              ),
              pw.SizedBox(height: 24),
              pw.TableHelper.fromTextArray(
                context: context,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerHeight: 25,
                cellHeight: 25,
                headers: ['No', 'Nama Komponen', 'Kondisi', 'Stok', 'Harga'],
                data: List<List<String>>.generate(products.length, (index) {
                  final product = products[index];
                  return [
                    (index + 1).toString(),
                    product.name,
                    product.descriptions ?? '-',
                    product.stock.toString(),
                    product.formattedPrice,
                  ];
                }),
              ),
            ];
          },
        ),
      );

      // Mengubah dokumen menjadi format byte agar bisa langsung diunduh
      final Uint8List bytes = await pdf.save();

      // Menggunakan sharePdf sebagai solusi agar file terunduh tanpa diblokir popup Chrome
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Laporan_Logistik_$dateStr.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat laporan PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard Analitik Logistik'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnalyticsData,
            tooltip: 'Refresh Analitik',
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAnalyticsData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.engineering,
                          size: 28,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            user?.displayName ?? user?.email ?? "Teknisi IT",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // TOMBOL CETAK PDF
                      ElevatedButton.icon(
                        onPressed: _isGeneratingPdf ? null : _generatePdfReport,
                        icon: _isGeneratingPdf
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf),
                        label: const Text('Cetak Laporan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Ringkasan Aset Kargo & Gudang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _isLoadingAnalytics
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isWeb ? 3 : 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isWeb ? 2.2 : 3.5,
                          children: [
                            _buildAnalyticsCard(
                              title: 'Jenis Komponen',
                              value: '$_totalItems Item',
                              icon: Icons.category,
                              color: Colors.blue,
                            ),
                            _buildAnalyticsCard(
                              title: 'Total Unit Stok',
                              value: '$_totalStock Unit',
                              icon: Icons.inventory_2,
                              color: Colors.orange,
                            ),
                            _buildAnalyticsCard(
                              title: 'Total Nilai Aset',
                              value: _formatRupiah(_totalAssetValue),
                              icon: Icons.monetization_on,
                              color: Colors.green,
                            ),
                          ],
                        ),

                  const SizedBox(height: 36),
                  const Text(
                    'Menu Operasional Logistik',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isWeb ? 2 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isWeb ? 2.5 : 3,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Inventaris Hardware',
                        subtitle: 'Kelola stok komponen, tambah & edit data',
                        icon: Icons.memory,
                        color: Colors.blue.shade800,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductListScreen(),
                            ),
                          );
                          _fetchAnalyticsData();
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Rute Distribusi Logistik',
                        subtitle: 'Lacak posisi kargo & live sensor suhu IoT',
                        icon: Icons.local_shipping,
                        color: Colors.green.shade700,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapDirectionScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

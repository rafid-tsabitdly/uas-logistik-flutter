import 'package:flutter/material.dart';
import '../service/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  // Variabel untuk menampung hasil Autocomplete
  String _selectedName = '';

  // Opsi Autocomplete (Materi UAS)
  static const List<String> _kategoriHardware = [
    'Baterai Laptop Advan Workplus',
    'Modul Port Charger Type-C',
    'Sensor Suhu IoT',
    'RAM 8GB DDR4',
    'SSD NVMe 512GB',
  ];

  // Variabel untuk Radio Button (Materi UAS)
  String _kondisiBarang = 'Baru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Stok Hardware'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. IMPLEMENTASI AUTOCOMPLETE
            const Text(
              'Nama Komponen:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _kategoriHardware.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                _selectedName = selection;
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Mulai ketik nama hardware...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => _selectedName = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    );
                  },
            ),
            const SizedBox(height: 16),

            // 2. IMPLEMENTASI RADIO BUTTON
            const Text(
              'Kondisi Barang:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Baru'),
                    value: 'Baru',
                    groupValue: _kondisiBarang,
                    onChanged: (value) =>
                        setState(() => _kondisiBarang = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Cabutan'),
                    value: 'Cabutan',
                    groupValue: _kondisiBarang,
                    onChanged: (value) =>
                        setState(() => _kondisiBarang = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Catatan / Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Jml Stok',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // 1. Siapkan data yang akan dikirim ke API
                  final Map<String, dynamic> data = {
                    'name': '$_selectedName ($_kondisiBarang)',
                    'descriptions': _descriptionController.text,
                    'price': int.tryParse(_priceController.text) ?? 0,
                    'stock': int.tryParse(_stockController.text) ?? 0,
                  };

                  // 2. Kirim ke Database melalui ApiService
                  final isSuccess = await ApiService.createProduct(data);

                  // 3. Beri notifikasi berdasarkan hasil
                  if (mounted) {
                    if (isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Berhasil menyimpan $_selectedName ke Database!',
                          ),
                        ),
                      );
                      Navigator.pop(context); // Kembali ke halaman list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menyimpan data ke Server API'),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Simpan Data Hardware',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ], // Akhir dari daftar children
        ), // Akhir dari ListView
      ), // Akhir dari Form
    ); // Akhir dari Scaffold
  }
}

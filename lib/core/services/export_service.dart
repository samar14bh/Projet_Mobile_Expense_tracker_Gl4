import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/statistics.dart';

enum ExportFormat { csv, pdf }
enum ExportScope { summary, detailed }

class ExportService {
  Future<String> generateExport({
    required ExportFormat format,
    required ExportScope scope,
    required DateTime month,
    required MonthlySummary summary,
    required List<CategorySpending> categorySpending,
    required List<DailySpending> dailySpending,
  }) async {
    if (format == ExportFormat.csv) {
      return _generateCsv(month, scope, summary, categorySpending, dailySpending);
    } else {
      return _generatePdf(month, scope, summary, categorySpending, dailySpending);
    }
  }

  Future<String> _generateCsv(
    DateTime month,
    ExportScope scope,
    MonthlySummary summary,
    List<CategorySpending> categorySpending,
    List<DailySpending> dailySpending,
  ) async {
    StringBuffer csvData = StringBuffer();
    csvData.writeln('Expense Report for ${DateFormat('MMMM yyyy').format(month)}');
    csvData.writeln('Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    csvData.writeln('');

    if (scope == ExportScope.summary || scope == ExportScope.detailed) {
      csvData.writeln('Summary');
      csvData.writeln('Total Spending,${summary.totalSpending.toStringAsFixed(2)}');
      csvData.writeln('Average Daily,${summary.averageDailySpending.toStringAsFixed(2)}');
      csvData.writeln('Highest Category,${summary.highestSpendingCategory}');
      csvData.writeln('');

      csvData.writeln('Category Breakdown');
      csvData.writeln('Category,Amount,Percentage');
      for (var item in categorySpending) {
        csvData.writeln(
            '${item.categoryName},${item.totalAmount.toStringAsFixed(2)},${item.percentage.toStringAsFixed(1)}%');
      }
      csvData.writeln('');
    }

    if (scope == ExportScope.detailed) {
      csvData.writeln('Daily Spending');
      csvData.writeln('Date,Amount');
      for (var item in dailySpending) {
        csvData.writeln(
            '${DateFormat('yyyy-MM-dd').format(item.date)},${item.totalAmount.toStringAsFixed(2)}');
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/report_${DateFormat('yyyy_MM').format(month)}.csv';
    final file = File(path);
    await file.writeAsString(csvData.toString());
    return path;
  }

  Future<String> _generatePdf(
    DateTime month,
    ExportScope scope,
    MonthlySummary summary,
    List<CategorySpending> categorySpending,
    List<DailySpending> dailySpending,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('MMMM yyyy').format(month), style: const pw.TextStyle(fontSize: 18)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                _buildPdfSummaryItem('Total Spending', summary.totalSpending),
                pw.SizedBox(width: 40),
                _buildPdfSummaryItem('Daily Average', summary.averageDailySpending),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                 pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Highest Category', style: const pw.TextStyle(color: PdfColors.grey)),
                    pw.Text(summary.highestSpendingCategory, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Category Breakdown', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              headers: ['Category', 'Amount', 'Percentage'],
              data: categorySpending
                  .map((e) => [
                        e.categoryName,
                        e.totalAmount.toStringAsFixed(2),
                        '${e.percentage.toStringAsFixed(1)}%'
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            ),
            if (scope == ExportScope.detailed) ...[
              pw.SizedBox(height: 20),
              pw.Text('Daily Spending', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                context: context,
                headers: ['Date', 'Amount'],
                data: dailySpending
                    .map((e) => [
                          DateFormat('yyyy-MM-dd').format(e.date),
                          e.totalAmount.toStringAsFixed(2),
                        ])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
            ],
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/report_${DateFormat('yyyy_MM').format(month)}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

  pw.Widget _buildPdfSummaryItem(String label, double value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey)),
        pw.Text(value.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

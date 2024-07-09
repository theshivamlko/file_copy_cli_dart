import 'dart:async';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    print('Usage: dart copy_file.dart <input_file> <output_file>');
    exit(1);
  }

  final inputFilePath = arguments[0];
  final outputFilePath = arguments[1];

  final inputFile = File(inputFilePath);
  final outputFile = File(outputFilePath);

  if (!await inputFile.exists()) {
    print('Error: Input file not found.');
    exit(1);
  }

  final totalBytes = await inputFile.length();
  int transferredBytes = 0;
  const int totalHashMarks = 20;
  int lastProgressPercent = 0;
  StreamSubscription? progressSubscription;

  double start = 0.0;

  await inputFile.openRead().pipe(outputFile.openWrite()).then((_) {
    progressSubscription?.cancel(); // Cancel if already subscribed
    progressSubscription = outputFile.openRead().listen((List<int> data) {
      transferredBytes += data.length;
      final progressPercent = (transferredBytes / totalBytes * 100).round();

      if (progressPercent >= lastProgressPercent + 5) {
        lastProgressPercent = progressPercent;

        final completedHashMarks =
            (progressPercent / 100 * totalHashMarks).round();
        final remainingHashMarks = totalHashMarks - completedHashMarks;

        final progressBar =
            '#' * completedHashMarks;
        stdout.write('\r$progressPercent% $progressBar');
      }
    }, onDone: () {
      print('\nFile copied successfully!');
    });
  });
}

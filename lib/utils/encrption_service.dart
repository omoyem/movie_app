import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as path;

class EncrptionService {

  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 chars
  static final _iv = encrypt.IV.fromLength(16);

  static Future<String> encryptFile(String inputPath) async {
    final file = File(inputPath);
    final bytes = await file.readAsBytes();
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encryptBytes(bytes, iv: _iv);
    final encryptedPath = inputPath + '.enc';
    await File(encryptedPath).writeAsBytes(encrypted.bytes);
    return encryptedPath;
  }

  static Future<String> decryptFile(String encryptedPath) async {
    final file = File(encryptedPath);
    final bytes = await file.readAsBytes();
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(bytes),
      iv: _iv,
    );
    final tempDir = Directory.systemTemp;
    final tempFilePath = path.join(tempDir.path, path.basenameWithoutExtension(encryptedPath));
    await File(tempFilePath).writeAsBytes(decrypted);
    return tempFilePath;
  }
}

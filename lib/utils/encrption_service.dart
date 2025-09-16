import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class EncrptionService {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); 
  static final _iv = encrypt.IV.fromLength(16);


  static Future<String> _getDecryptedFilesPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final decryptedDir = Directory('${dir.path}/decrypted_movies');
    
    if (!await decryptedDir.exists()) {
      await decryptedDir.create(recursive: true);
    }
    
    return decryptedDir.path;
  }

  static Future<String> encryptFile(String inputPath) async {
    final file = File(inputPath);
    final bytes = await file.readAsBytes();
    
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encryptBytes(bytes, iv: _iv);
    
    final encryptedPath = inputPath + '.enc';
    await File(encryptedPath).writeAsBytes(encrypted.bytes);
    
    return encryptedPath;
  }

  static Future<String> getDecryptedFilePath(String encryptedPath) async {
    final decryptedDir = await _getDecryptedFilesPath();
    final fileName = path.basenameWithoutExtension(encryptedPath);
    return path.join(decryptedDir, '$fileName.mp4');
  }

  static Future<bool> isAlreadyDecrypted(String encryptedPath) async {
    final decryptedPath = await getDecryptedFilePath(encryptedPath);
    return await File(decryptedPath).exists();
  }

  static Future<String> decryptFile(String encryptedPath) async {
    final decryptedPath = await getDecryptedFilePath(encryptedPath);
    
   
    if (await File(decryptedPath).exists()) {
      print('Decrypted file already exists: $decryptedPath');
      return decryptedPath;
    }

   
    print('Decrypting file: $encryptedPath');
    final file = File(encryptedPath);
    final bytes = await file.readAsBytes();
    
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(bytes),
      iv: _iv,
    );
    
    await File(decryptedPath).writeAsBytes(decrypted);
    print('File decrypted to: $decryptedPath');
    
    return decryptedPath;
  }

  
  static Future<void> deleteDecryptedFile(String encryptedPath) async {
    try {
      final decryptedPath = await getDecryptedFilePath(encryptedPath);
      final file = File(decryptedPath);
      
      if (await file.exists()) {
        await file.delete();
        print('Deleted decrypted file: $decryptedPath');
      }
    } catch (e) {
      print('Error deleting decrypted file: $e');
    }
  }

  static Future<int> getDecryptedFilesSize() async {
    try {
      final decryptedDir = await _getDecryptedFilesPath();
      final dir = Directory(decryptedDir);
      
      if (!await dir.exists()) return 0;
      
      int totalSize = 0;
      await for (var file in dir.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating decrypted files size: $e');
      return 0;
    }
  }


  static Future<void> cleanupAllDecryptedFiles() async {
    try {
      final decryptedDir = await _getDecryptedFilesPath();
      final dir = Directory(decryptedDir);
      
      if (await dir.exists()) {
        await for (var file in dir.list()) {
          if (file is File) {
            await file.delete();
            print('Deleted decrypted file: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up all decrypted files: $e');
    }
  }

  // Get list of all decrypted files
  static Future<List<String>> getDecryptedFilesList() async {
    try {
      final decryptedDir = await _getDecryptedFilesPath();
      final dir = Directory(decryptedDir);
      
      if (!await dir.exists()) return [];
      
      List<String> files = [];
      await for (var file in dir.list()) {
        if (file is File) {
          files.add(file.path);
        }
      }
      
      return files;
    } catch (e) {
      print('Error getting decrypted files list: $e');
      return [];
    }
  }
}
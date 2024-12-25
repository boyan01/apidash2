import 'package:apidash/consts.dart';
import 'package:apidash_core/apidash_core.dart';

class Importer {
  Future<List<(String?, HttpRequestModel)>?> getHttpRequestModelList(
    ImportFormat fileType,
    String content,
  ) async {
    return switch (fileType) {
      ImportFormat.curl => CurlIO()
          .getHttpRequestModelList(content)
          ?.map((t) => (null, t))
          .toList(),
      ImportFormat.postman => null
    };
  }
}

final kImporter = Importer();

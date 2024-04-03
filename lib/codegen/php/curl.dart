import 'package:jinja/jinja.dart' as jj;
import 'package:apidash/utils/utils.dart' show getValidRequestUri, stripUriParams;
import 'package:apidash/models/models.dart' show RequestModel;
import 'package:apidash/consts.dart';

class PHPcURLCodeGen {
  final String kTemplateStart = r'''
<?php


''';

  final String kTemplateUri = r'''
$uri = '{{uri}}';


''';

  String kTemplateBody = r'''
{%- if body is iterable -%}
$request_body = [
{%- for data in body %}
{%- if data.type == 'text' %}
    '{{ data.name }}' => '{{ data.value }}',
{%- elif data.type == 'file' %}
    '{{ data.name }}' => new CURLFILE('{{ data.value }}'),
{%- endif %}
{%- endfor %}
];
{%- else -%}
$request_body = '{{body}}';
{%- endif %}


''';

  //defining query parameters
  String kTemplateParams = r'''
$queryParams = [
{%- for name, value in params %}
    '{{ name }}' => '{{ value }}',
{%- endfor %}
];
$uri .= '?' . http_build_query($queryParams);


''';

  //specifying headers
  String kTemplateHeaders = r'''
$headers = [
{%- for name, value in headers %}
    '{{ name }}: {{ value }}',
{%- endfor %}
];


''';

  //initialising the request
  String kStringRequestInit = r'''
$request = curl_init($uri);

''';

  String kTemplateRequestOptsInit = r'''
curl_setopt_array($request, [
    CURLOPT_RETURNTRANSFER => 1,
    CURLOPT_CUSTOMREQUEST => '{{ method|upper }}',

''';
  String kStringHeaderOpt = r'''
    CURLOPT_HTTPHEADER => $headers,
''';
  //passing the request body
  String kStringRequestBodyOpt = r'''
    CURLOPT_POSTFIELDS => $request_body,
''';

  //ending template
  final String kStringRequestEnd = r'''
    CURLOPT_SSL_VERIFYPEER => 0,
    CURLOPT_MAXREDIRS => 10,
    CURLOPT_TIMEOUT => 0,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
]);

$response = curl_exec($request);

curl_close($request);

$httpCode = curl_getinfo($request, CURLINFO_HTTP_CODE);
echo "Status Code: " . $httpCode . "\n";
echo $response;
''';

  String? getCode(RequestModel requestModel) {
    try {
      String result = "";
      bool hasHeaders = false;
      bool hasQuery = false;
      bool hasBody = false;

      var rec = getValidRequestUri(
        requestModel.url,
        requestModel.enabledRequestParams,
      );

      Uri? uri = rec.$1;

      //renders starting template
      if (uri != null) {
        var templateStart = jj.Template(kTemplateStart);
        result += templateStart.render();

        var templateUri = jj.Template(kTemplateUri);
        result += templateUri.render({'uri': stripUriParams(uri)});

        //renders the request body contains the HTTP method associated with the request
        if (kMethodsWithBody.contains(requestModel.method) && requestModel.hasBody) {
          hasBody = true;
          // contains the entire request body as a string if body is present
          var templateBody = jj.Template(kTemplateBody);
          result += templateBody.render({
            'body': requestModel.hasFormData ? requestModel.formDataMapList : requestModel.requestBody,
          });
        }

        //checking and adding query params
        if (uri.hasQuery) {
          if (requestModel.enabledParamsMap.isNotEmpty) {
            hasQuery = true;
            var templateParams = jj.Template(kTemplateParams);
            result += templateParams.render({"params": requestModel.enabledParamsMap});
          }
        }

        var headers = requestModel.enabledHeadersMap;
        if (requestModel.hasBody) {
          if (!headers.containsKey('Content-Type')) {
            if (requestModel.hasJsonData) {
              headers['Content-Type'] = 'application/json';
            } else if (requestModel.hasTextData) {
              headers['Content-Type'] = 'text/plain';
            }
          }
        }

        if (headers.isNotEmpty) {
          var templateHeader = jj.Template(kTemplateHeaders);
          result += templateHeader.render({'headers': headers});
        }

        // renders the initial request init function call
        result += kStringRequestInit;

        //renders the request temlate
        var templateRequestOptsInit = jj.Template(kTemplateRequestOptsInit);
        result += templateRequestOptsInit.render({'method': requestModel.method.name});
        if (headers.isNotEmpty) {
          result += kStringHeaderOpt;
        }
        if (hasBody || requestModel.hasFormData) {
          result += kStringRequestBodyOpt;
        }

        //and of the request
        result += kStringRequestEnd;
      }
      return result;
    } catch (e) {
      return null;
    }
  }
}

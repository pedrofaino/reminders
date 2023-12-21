
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:uni_links/uni_links.dart';

void initURIHandler(BuildContext context) async {
  final logger = Logger();
  uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      try {
        context.goNamed('confirmation', extra: uri);
      } catch (e) {
        logger.e(e);
      }
    }
  }, onError: (Object err) {
    logger.e('Error occurred: $err');
  });
}

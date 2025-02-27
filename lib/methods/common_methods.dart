// ignore_for_file: curly_braces_in_flow_control_structures, unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    // check internet connection
    var connectionResult = await (Connectivity().checkConnectivity());

    if (connectionResult != ConnectivityResult.mobile &&
        connectionResult != ConnectivityResult.wifi) {
      if (!context.mounted)
        // ignore: use_build_context_synchronously
        return displaySnackBar("'No internet connection'", context);
    }
  }

  displaySnackBar(String message, BuildContext context) {
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error, BuildContext context) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppLocalizations.of(context)!.errorNetworkTimeout;
        case DioExceptionType.badResponse:
          return _handleResponseError(error.response, context);
        case DioExceptionType.connectionError:
          return AppLocalizations.of(context)!.errorNetworkConnection;
        default:
          return AppLocalizations.of(context)!.errorUnknown;
      }
    }
    return error.toString();
  }

  static String _handleResponseError(Response? response, BuildContext context) {
    if (response == null) return AppLocalizations.of(context)!.errorUnknown;

    switch (response.statusCode) {
      case 400:
        return _parseErrorMessage(response.data) ?? 
            AppLocalizations.of(context)!.errorBadRequest;
      case 401:
        return AppLocalizations.of(context)!.errorUnauthorized;
      case 403:
        return AppLocalizations.of(context)!.errorForbidden;
      case 404:
        return AppLocalizations.of(context)!.errorNotFound;
      case 500:
        return AppLocalizations.of(context)!.errorServer;
      default:
        return AppLocalizations.of(context)!.errorUnknown;
    }
  }

  static String? _parseErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'];
    }
    return null;
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
} 
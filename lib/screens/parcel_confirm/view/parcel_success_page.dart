import 'package:flutter/material.dart';
import 'package:hyper_local/config/securestorage_helper.dart';
import 'package:hyper_local/l10n/app_localizations.dart';

class ParcelSuccessScreen extends StatelessWidget {
  const ParcelSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
     
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A73E8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 30),
                  FutureBuilder<String?>(
  future: SecureStorageHelper.getParcelNumber(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const SizedBox();
    }

    final pbNumber = snapshot.data ?? "";

    print("Fetched Parcel Number for Success Screen: $pbNumber");

    return Text(
      "Order ID: $pbNumber",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
    );
  },
),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.parcelRequestSubmittedSuccessfully ?? "Parcel Request Submitted Successfully",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                    l10n?.youWillReceiveNotifications ??   "You will receive notifications at each stage",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Button at Bottom
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child:  Text(
                l10n?.backToHome ??   "Back to Home",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

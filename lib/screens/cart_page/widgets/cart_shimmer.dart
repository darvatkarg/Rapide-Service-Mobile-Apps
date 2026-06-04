import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hyper_local/utils/widgets/custom_shimmer.dart';

class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Store Section Shimmer
        Container(
          margin: EdgeInsets.only(bottom: 9.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              // Store Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidget.rectangular(
                        height: 20.h, width: 120.w, isBorder: true),
                    ShimmerWidget.rectangular(
                        height: 15.h, width: 60.w, isBorder: true),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Cart Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ShimmerWidget.rectangular(
                        height: 50.h,
                        width: 50.h,
                        borderRadius: 8,
                        isBorder: true,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.rectangular(
                                height: 15.h, width: 140.w, isBorder: true),
                            SizedBox(height: 6.h),
                            ShimmerWidget.rectangular(
                                height: 10.h, width: 80.w, isBorder: true),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ShimmerWidget.rectangular(
                          height: 30.h,
                          width: 60.w,
                          borderRadius: 6,
                          isBorder: true),
                      SizedBox(width: 10.w),
                      ShimmerWidget.rectangular(
                          height: 20.h, width: 50.w, isBorder: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Delivery Type Shimmer
        Container(
          margin: EdgeInsets.only(bottom: 9.h),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              ShimmerWidget.rectangular(
                  height: 40.h, width: 40.h, borderRadius: 8, isBorder: true),
              SizedBox(width: 12.w),
              Expanded(
                  child:
                      ShimmerWidget.rectangular(height: 20.h, isBorder: true)),
            ],
          ),
        ),

        // Bill Summary Shimmer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: List.generate(
                4,
                (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerWidget.rectangular(
                              height: 15.h, width: 100.w, isBorder: true),
                          ShimmerWidget.rectangular(
                              height: 15.h, width: 60.w, isBorder: true),
                        ],
                      ),
                    )),
          ),
        ),
      ],
    );
  }
}

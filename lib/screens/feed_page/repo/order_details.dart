import 'package:hyper_local/config/api_routes.dart';
import '../../../config/api_base_helper.dart';

class OrderDetailsRepo {
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: '$orderDetailsApi/$orderId',
        useAuthToken: true,
        params: {},
      );

      return response;
    } catch (error) {
      throw Exception('Error occurred while fetching order details');
    }
  }

  Future<Map<String, dynamic>> getParcelDetails(String pbId) async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: '$parcelDetailsApi/$pbId',
        useAuthToken: true,
        params: {},
      );

      return response;
    } catch (error) {
      throw Exception('Error occurred while fetching parcel details');
    }
  }

  Future<Map<String, dynamic>> changeParcelStatus({
    required String pbId,
    required String status,
  }) async {
    try {
      final response = await ApiBaseHelper.post(
        url: '$parcelDetailsApi/$pbId/status',
        useAuthToken: true,
        body: {"status": status},
      );

      return response;
    } catch (error) {
      throw Exception('Error occurred while updating parcel status');
    }
  }

  Future<Map<String, dynamic>> changeOrderStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await ApiBaseHelper.post(
        url: '$orderDetailsApi/$id/status',
        useAuthToken: true,
        body: {"status": status},
      );

      return response;
    } catch (error) {
      throw Exception('Error occurred while updating parcel status');
    }
  }
}

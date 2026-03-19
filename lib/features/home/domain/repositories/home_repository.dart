import '../../../home/data/models/banner_model.dart';

/// Abstract contract for home/CMS data — banners, announcements.
abstract class HomeRepository {
  /// Get active banners from Super Admin CMS.
  Future<List<BannerModel>> getBanners();
}

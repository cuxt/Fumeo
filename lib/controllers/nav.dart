import 'package:fumeo/routes/routes.dart';
import 'package:get/get.dart';

class NavController extends GetxController {
  final _currentIndex = 0.obs;

  int get currentIndex => _currentIndex.value;

  final List<String> _routeHistory = [];

  void changePage(int index) {
    if (_currentIndex.value != index) {
      _currentIndex.value = index;
      _updateRouteHistory(index);
    }
  }

  void _updateRouteHistory(int index) {
    final route = _getRouteForIndex(index);
    if (route != _routeHistory.lastOrNull) {
      _routeHistory.add(route);
    }
  }

  String _getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return Routes.home;
      case 1:
        return Routes.todo;
      case 2:
        return Routes.explore;
      case 3:
        return Routes.mine;
      default:
        return Routes.home;
    }
  }

  Future<bool> onWillPop() async {
    if (_routeHistory.length > 1) {
      _routeHistory.removeLast();
      final lastRoute = _routeHistory.last;
      final index = _getIndexForRoute(lastRoute);
      _currentIndex.value = index;
      return false;
    }
    return true;
  }

  int _getIndexForRoute(String route) {
    switch (route) {
      case Routes.home:
        return 0;
      case Routes.todo:
        return 1;
      case Routes.explore:
        return 2;
      case Routes.mine:
        return 3;
      default:
        return 0;
    }
  }
}

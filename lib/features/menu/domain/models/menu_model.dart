class MenuModel {
  String icon;
  String title;
  String route;
  bool isBlocked;
  bool isNotSubscribe;

  MenuModel({required this.icon, required this.title, required this.route, this.isBlocked = false, this.isNotSubscribe = false});
}
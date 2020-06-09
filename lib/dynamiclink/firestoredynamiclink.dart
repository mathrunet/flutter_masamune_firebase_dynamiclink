part of masamune.firebase.mobile;

/// Get Dynamic Link.
///
/// The URI is acquired at the first start and in the application.
class FirestoreDynamicLink extends Task<Uri> implements ITask {
  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class
  @override
  @protected
  Completer createCompleter() => Completer<FirestoreDynamicLink>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FirestoreDynamicLink._(
          path: path,
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;
  Firebase get _app {
    if (this.__app == null) this.__app = Firebase(this.protocol);
    return this.__app;
  }

  Firebase __app;
  FirebaseDynamicLinks get _dynamicLink {
    if (this.__dynamicLink == null)
      this.__dynamicLink = FirebaseDynamicLinks.instance;
    return this.__dynamicLink;
  }

  FirebaseDynamicLinks __dynamicLink;

  /// Get Dynamic Link.
  ///
  /// The URI is acquired at the first start and in the application.
  factory FirestoreDynamicLink() {
    if (Config.isWeb) {
      Log.warning("This platform is not supported.");
      return null;
    }
    FirestoreDynamicLink unit = PathMap.get<FirestoreDynamicLink>(_systemPath);
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. Please execute [listen()] first.");
    return null;
  }

  /// Get Dynamic Link.
  ///
  /// The URI is acquired at the first start and in the application.
  static Future<FirestoreDynamicLink> listen() {
    if (Config.isWeb) {
      Log.msg("This platform is not supported.");
      return Future.delayed(Duration.zero);
    }
    FirestoreDynamicLink unit = PathMap.get<FirestoreDynamicLink>(_systemPath);
    if (unit != null) return unit.future;
    unit = FirestoreDynamicLink._(path: _systemPath);
    unit._constructListener();
    return unit.future;
  }

  FirestoreDynamicLink._(
      {String path,
      dynamic value,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(
            path: path,
            value: value,
            isTemporary: isTemporary,
            group: group,
            order: order);
  static const String _systemPath = "system://firebasedynamiclink";
  void _constructListener() async {
    try {
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._dynamicLink == null)
        this.__dynamicLink = FirebaseDynamicLinks.instance;
      PendingDynamicLinkData data = await this._dynamicLink.getInitialLink();
      this._dynamicLink.onLink(
          onSuccess: this._done,
          onError: (error) async {
            Log.error(error.message);
          });
      this.data = data?.link;
      this.done();
    } catch (e) {
      this.error(e.toString());
    }
  }

  Future _done(PendingDynamicLinkData data) async {
    this.init();
    this.data = data?.link;
    this.done();
  }

  /// Get the protocol of the path.
  @override
  String get protocol => "firestore";

  /// When map data is stored.
  /// You can get the data by specifying the path.
  ///
  /// [path]: The path to get the data.
  @override
  dynamic operator [](String path) {
    if (isEmpty(path)) return null;
    path = path.trimString(Const.slash);
    Uri tmp = this.data;
    if (tmp == null || tmp.queryParameters == null) return null;
    if (!tmp.queryParameters.containsKey(path)) return null;
    return tmp.queryParameters[path];
  }
}

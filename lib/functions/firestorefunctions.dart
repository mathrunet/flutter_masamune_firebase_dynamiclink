part of masamune.firebase.mobile;

/// Class for handling Firebase / Firestore Functions.
///
/// First, specify protocol and region to initialize.
///
/// Normally, you can use it without specifying it explicitly.
class FirestoreFunctions extends TaskUnit {
  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<FirestoreFunctions>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FirestoreFunctions._(
        path: path,
      ) as T;
  FirebaseCore get _app {
    if (this.__app == null) this.__app = FirebaseCore(this.protocol);
    return this.__app;
  }

  FirebaseCore __app;
  FirestoreAuth get _auth {
    if (this.__auth == null) this.__auth = FirestoreAuth(this.protocol);
    return this.__auth;
  }

  FirestoreAuth __auth;
  CloudFunctions get _functions => this.__functions;
  CloudFunctions __functions;

  /// Search for an instance of FirestoreFunctions from [protocol] / [region].
  ///
  /// [protocol]: Protocol.
  /// [region]: Region.
  factory FirestoreFunctions({String protocol, String region}) {
    if (isEmpty(protocol)) protocol = "firestore";
    if (isEmpty(region)) region = "asia-northeast1";
    String path = Texts.format(_systemPath, [protocol, region]);
    FirestoreFunctions unit = PathMap.get<FirestoreFunctions>(path);
    if (unit != null) return unit;
    unit = PathMap.get<FirestoreFunctions>(
        Texts.format(_systemPath, [Const.empty, Const.empty]));
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. Please execute [initialize()] first.");
    return null;
  }

  /// Class for handling Firebase / Firestore Functions.
  ///
  /// First, specify protocol and region to initialize.
  ///
  /// Normally, you can use it without specifying it explicitly.
  ///
  /// [timeout]: Timeout time
  static Future<FirestoreFunctions> initialize(
          {Duration timeout = Const.timeout}) =>
      FirestoreFunctions.configure(timeout: timeout);

  /// Class for handling Firebase / Firestore Functions.
  ///
  /// First, specify protocol and region to initialize.
  ///
  /// Normally, you can use it without specifying it explicitly.
  ///
  /// [protocol]: Firebase protocol.
  /// [region]: Functions region.
  /// [timeout]: Timeout time.
  static Future<FirestoreFunctions> configure(
      {String protocol, String region, Duration timeout = Const.timeout}) {
    if (Config.isWeb) {
      Log.error("This platform is not supported.");
      return Future.delayed(Duration.zero);
    }
    if (isEmpty(protocol)) protocol = "firestore";
    if (isEmpty(region)) region = "asia-northeast1";
    String path = Texts.format(_systemPath, [protocol, region]);
    FirestoreFunctions unit = PathMap.get<FirestoreFunctions>(path);
    if (unit != null) return unit.future;
    unit = FirestoreFunctions._(path: path);
    unit._createFunctionsProcess(protocol, region, timeout);
    return unit.future;
  }

  FirestoreFunctions._({String path}) : super(path: path, group: -1);
  void _createFunctionsProcess(
      String protocol, String region, Duration timeout) async {
    try {
      if (this._app == null) this.__app = await FirebaseCore.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: protocol);
      this.__functions = CloudFunctions(app: this._app.app, region: region);
      this.done();
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  static const String _systemPath = "system://api/%s/%s";

  /// Get the protocol of the path.
  @override
  String get protocol => "firestore";
}

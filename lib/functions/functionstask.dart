part of masamune.firebase.mobile;

/// Task class for executing Firebase Functions functions.
///
/// Execute the task with the [call()] method and wait for it to complete with await.
///
/// The result is stored in the [data] property.
class FunctionsTask extends Task {
  static RegExp _regExp = RegExp("^[a-zA-Z0-9]+-[a-zA-Z0-9]+");

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<FunctionsTask>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FunctionsTask._(
          path: path,
          isTemporary: isTemporary,
          order: this.order,
          group: this.group) as T;
  Firebase get _app {
    if (this.__app == null) this.__app = Firebase(this.protocol);
    return this.__app;
  }

  Firebase __app;
  FirestoreAuth get _auth {
    if (this.__auth == null) this.__auth = FirestoreAuth(this.protocol);
    return this.__auth;
  }

  FirestoreAuth __auth;
  FirestoreFunctions get _functions {
    if (this.__functions == null) {
      this.__functions =
          FirestoreFunctions(protocol: this.protocol, region: this.region);
    }
    return this.__functions;
  }

  FirestoreFunctions __functions;
  HttpsCallable get _callable {
    if (this.__callable == null) {
      this.__callable = this
          ._functions
          ?._functions
          ?.getHttpsCallable(functionName: this.rawPath.file);
    }
    return this.__callable;
  }

  HttpsCallable __callable;

  /// Task class for executing Firebase Functions functions.
  ///
  /// Execute the task with the [call()] method and wait for it to complete with await.
  ///
  /// The result is stored in the [postData] property.
  ///
  /// [path]: Specify the execution function of Functions in URL format (https://～).
  factory FunctionsTask(String path) {
    if (Config.isWeb) {
      Log.warning("This platform is not supported.");
      return null;
    }
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return null;
    }
    FunctionsTask unit = PathMap.get<FunctionsTask>(path);
    if (unit != null) return unit;
    Log.warning(
        "No data was found from the pathmap. Please execute [call()] first.");
    return null;
  }

  /// Task class for executing Firebase Functions functions.
  ///
  /// Execute the task with the [call()] method and wait for it to complete with await.
  ///
  /// The result is stored in the [postData] property.
  ///
  /// [path]: Specify the execution function of Functions in URL format (https://～).
  /// [defaultData]: Initial value when the function is not executed.
  /// [postData]: Parameters to pass to the function.
  /// [timeout]: Timeout time.
  static Future<FunctionsTask> call(String path,
      {dynamic defaultValue,
      Map<String, dynamic> postData = const {},
      Duration timeout = Const.timeout}) {
    if (Config.isWeb) {
      Log.warning("This platform is not supported.");
      return Future.delayed(Duration.zero);
    }
    path = path?.replaceAll("https", "firestore")?.applyTags();
    assert(isNotEmpty(path));
    if (isEmpty(path)) {
      Log.error("Path is invalid.");
      return Future.delayed(Duration.zero);
    }
    FunctionsTask unit = PathMap.get<FunctionsTask>(path);
    if (unit != null) {
      return unit.recall(
          defaultValue: defaultValue, data: postData, timeout: timeout);
    }
    unit = FunctionsTask._(path: path);
    if (defaultValue != null) unit.data = defaultValue;
    unit._call(postData, timeout);
    return unit.future;
  }

  /// Run the function again.
  ///
  /// [defaultData]: Initial value when the function is not executed.
  /// [postData]: Parameters to pass to the function.
  /// [timeout]: Timeout time.
  Future<FunctionsTask> recall(
      {dynamic defaultValue,
      Map<String, dynamic> data = const {},
      Duration timeout = Const.timeout}) {
    this.init();
    if (defaultValue != null) this.data = defaultValue;
    this._call(data, timeout);
    return this.future;
  }

  void _call(Map<String, dynamic> data, Duration timeout) async {
    try {
      if (this._app == null) this.__app = await Firebase.initialize();
      if (this._auth == null)
        this.__auth = await FirestoreAuth.signIn(protocol: this.protocol);
      if (this._functions == null) {
        this.__functions = await FirestoreFunctions.configure(
            protocol: this.protocol, region: this.region);
      }
      if (this._callable == null) {
        this.__callable = this
            ._functions
            ._functions
            .getHttpsCallable(functionName: this.rawPath.file);
      }
      if (data == null || data.length <= 0) {
        this.data = (await this._callable.call().timeout(timeout))?.data;
      } else {
        this.data = (await this._callable.call(data).timeout(timeout))?.data;
      }
      this.done();
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  FunctionsTask._(
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

  /// Functions region.
  String get region {
    if (this._region != null) return this._region;
    if (this.rawPath == null || isEmpty(this.rawPath.path))
      return "asia-northeast1";
    RegExpMatch match = _regExp.firstMatch(this.rawPath.path);
    if (match != null) return this._region = match.group(0);
    return null;
  }

  String _region;

  /// Get the protocol of the path.
  @override
  String get protocol {
    if (isEmpty(this.rawPath.scheme)) return "firestore";
    return this.rawPath.scheme;
  }
}

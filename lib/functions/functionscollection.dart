part of masamune.firebase.mobile;

/// Task class for executing Firebase Functions functions.
///
/// Execute the task with the [call()] method and wait for it to complete with await.
///
/// The function must be two layer of Map data.
///
/// Parse Map data and use it as a collection.
class FunctionsCollection extends TaskCollection<DataDocument>
    with SortableDataCollectionMixin<DataDocument>
    implements ITask, IDataCollection<DataDocument> {
  static RegExp _regExp = RegExp("^[a-zA-Z0-9]+-[a-zA-Z0-9]+");

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<FunctionsCollection>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FunctionsCollection._(
          path: path,
          isTemporary: isTemporary,
          order: this.order,
          group: this.group,
          orderBy: this.orderBy,
          orderByKey: this.orderByKey,
          thenBy: this.thenBy,
          thenByKey: this.thenByKey) as T;
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
  /// The function must be two layer of Map data.
  ///
  /// Parse Map data and use it as a collection.
  ///
  /// [path]: Specify the execution function of Functions in URL format (https://～).
  factory FunctionsCollection(String path) {
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
    FunctionsCollection collection = PathMap.get<FunctionsCollection>(path);
    if (collection != null) return collection;
    Log.warning(
        "No data was found from the pathmap. Please execute [call()] first.");
    return null;
  }

  /// Task class for executing Firebase Functions functions.
  ///
  /// Execute the task with the [call()] method and wait for it to complete with await.
  ///
  /// The function must be two layer of Map data.
  ///
  /// Parse Map data and use it as a collection.
  ///
  /// [path]: Specify the execution function of Functions in URL format (https://～).
  /// [defaultData]: Initial value when the function is not executed.
  /// [postData]: Parameters to pass to the function.
  /// [timeout]: Timeout time.
  static Future<FunctionsCollection> call(String path,
      {Iterable<DataDocument> defaultValue,
      Map<String, dynamic> data = const {},
      Duration timeout = Const.timeout,
      OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey}) {
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
    FunctionsCollection collection = PathMap.get<FunctionsCollection>(path);
    if (collection != null) {
      if (orderBy != OrderBy.none) collection.orderBy = orderBy;
      if (thenBy != OrderBy.none) collection.thenBy = thenBy;
      if (isNotEmpty(orderByKey)) collection.orderByKey = orderByKey;
      if (isNotEmpty(thenByKey)) collection.thenByKey = thenByKey;
      return collection.recall(
          defaultValue: defaultValue, data: data, timeout: timeout);
    }
    collection = FunctionsCollection._(
        path: path,
        value: defaultValue,
        orderBy: orderBy,
        thenBy: thenBy,
        orderByKey: orderByKey,
        thenByKey: thenByKey);
    collection._call(data, timeout);
    return collection.future;
  }

  /// Run the function again.
  ///
  /// [defaultData]: Initial value when the function is not executed.
  /// [postData]: Parameters to pass to the function.
  /// [timeout]: Timeout time.
  Future<FunctionsCollection> recall(
      {Iterable<DataDocument> defaultValue,
      Map<String, dynamic> data = const {},
      Duration timeout = Const.timeout}) {
    this.init();
    if (defaultValue != null) {
      this.clear();
      defaultValue?.forEach((doc) => this.setInternal(doc));
    }
    this._call(data, timeout);
    return this.future;
  }

  void _call(Map<String, dynamic> data, Duration timeout) async {
    try {
      if (this._app == null) this.__app = await FirebaseCore.initialize();
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
      Map<dynamic, dynamic> res;
      if (data == null || data.length <= 0) {
        res = (await this._callable.call().timeout(timeout))?.data;
      } else {
        res = (await this._callable.call(data).timeout(timeout))?.data;
      }
      if (res == null || res.length <= 0) {
        this.sort();
        this.done();
        return;
      }
      this._build(res)?.forEach((doc) => this.setInternal(doc));
      this.sort();
      this.done();
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  Iterable<DataDocument> _build(Map<dynamic, dynamic> data) {
    List<DataDocument> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      if (!(value is Map)) return;
      list.add(DataDocument.fromMap(
          Paths.child(this.path, key.toString()),
          value.map<String, dynamic>(
              (k, v) => MapEntry<String, dynamic>(k.toString(), v))));
    });
    return list;
  }

  FunctionsCollection._({
    String path,
    Iterable<DataDocument> value,
    bool isTemporary = false,
    int group = 0,
    int order = 10,
    OrderBy orderBy = OrderBy.none,
    OrderBy thenBy = OrderBy.none,
    String orderByKey,
    String thenByKey,
  }) : super(
            path: path,
            children: value,
            isTemporary: isTemporary,
            group: group,
            order: order) {
    this.orderBy = orderBy;
    this.orderByKey = orderByKey;
    this.thenBy = thenBy;
    this.thenByKey = thenByKey;
  }

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

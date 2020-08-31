part of masamune.firebase.mobile;

/// Task class for executing Firebase Functions functions.
///
/// Execute the task with the [call()] method and wait for it to complete with await.
///
/// The function must be one layer of Map data.
///
/// Parse Map data and use it as a document.
class FunctionsDocument extends TaskDocument<DataField>
    with DataDocumentMixin<DataField>
    implements ITask, IDataDocument<DataField> {
  static RegExp _regExp = RegExp("^[a-zA-Z0-9]+-[a-zA-Z0-9]+");

  /// Create a Completer that matches the class.
  ///
  /// Do not use from external class.
  @override
  @protected
  Completer createCompleter() => Completer<FunctionsDocument>();

  /// Process to create a new instance.
  ///
  /// Do not use from outside the class.
  ///
  /// [path]: Destination path.
  /// [isTemporary]: True if the data is temporary.
  @override
  @protected
  T createInstance<T extends IClonable>(String path, bool isTemporary) =>
      FunctionsDocument._(
          path: path,
          isTemporary: isTemporary,
          group: this.group,
          order: this.order) as T;
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
  /// The function must be one layer of Map data.
  ///
  /// Parse Map data and use it as a document.
  ///
  /// [path]: Specify the execution function of Functions in URL format (https://～).
  factory FunctionsDocument(String path) {
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
    FunctionsDocument document = PathMap.get<FunctionsDocument>(path);
    if (document != null) return document;
    Log.warning(
        "No data was found from the pathmap. Please execute [call()] first.");
    return null;
  }

  /// Task class for executing Firebase Functions functions.
  ///
  /// Execute the task with the [call()] method and wait for it to complete with await.
  ///
  /// The function must be one layer of Map data.
  ///
  /// Parse Map data and use it as a document.
  ///
  /// [path]: Specify the execution function of Functions in URL format (https://～).
  /// [defaultData]: Initial value when the function is not executed.
  /// [postData]: Parameters to pass to the function.
  /// [timeout]: Timeout time.
  static Future<FunctionsDocument> call(String path,
      {Map<String, dynamic> defaultValue,
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
    FunctionsDocument document = PathMap.get<FunctionsDocument>(path);
    if (document != null) {
      return document.recall(
          defaultValue: defaultValue, data: data, timeout: timeout);
    }
    document = FunctionsDocument._(path: path);
    if (defaultValue != null) {
      defaultValue?.forEach(
          (key, value) => document.setInternal(DataField(key, value)));
    }
    document._call(data, timeout);
    return document.future;
  }

  /// Run the function again.
  ///
  /// [defaultData]: Initial value when the function is not executed.
  /// [postData]: Parameters to pass to the function.
  /// [timeout]: Timeout time.
  Future<FunctionsDocument> recall(
      {Map<String, dynamic> defaultValue,
      Map<String, dynamic> data = const {},
      Duration timeout = Const.timeout}) {
    this.init();
    if (defaultValue != null) {
      this.clear();
      if (defaultValue != null) {
        defaultValue
            ?.forEach((key, value) => this.setInternal(DataField(key, value)));
      }
    }
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
      Map<dynamic, dynamic> res;
      if (data == null || data.length <= 0) {
        res = (await this._callable.call().timeout(timeout))?.data;
      } else {
        res = (await this._callable.call(data).timeout(timeout))?.data;
      }
      if (res == null || res.length <= 0) {
        this.done();
        return;
      }
      this._build(res)?.forEach((val) => this.setInternal(val));
      this.done();
    } on TimeoutException catch (e) {
      this.timeout(e.toString());
    } catch (e) {
      this.error(e.toString());
    }
  }

  Iterable<DataField> _build(Map<dynamic, dynamic> data) {
    List<DataField> list = ListPool.get();
    data?.forEach((key, value) {
      if (isEmpty(key) || value == null) return;
      if (!(value is Map)) return;
      if (value is DataField) {
        String child = Paths.child(this.path, key.toString());
        if (value.path == child)
          list.add(value);
        else
          list.add(value.clone(path: child, isTemporary: false));
      } else {
        list.add(DataField(Paths.child(this.path, key.toString()), value));
      }
    });
    return list;
  }

  FunctionsDocument._(
      {String path,
      Iterable<DataField> value,
      bool isTemporary = false,
      int group = 0,
      int order = 10})
      : super(
            path: path,
            children: value,
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

  /// Create a new field.
  ///
  /// [path]: Field path.
  /// [value]: Field value.
  @override
  DataField createField([String path, value]) => DataField(path, value);
}

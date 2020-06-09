// Copyright 2020 mathru. All rights reserved.

/// Masamune firebase mobile framework library.
///
/// To use, import `package:masamune_firebase_mobile/masamune_firebase_mobile.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library masamune.firebase.mobile;

import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:masamune_core/masamune_core.dart';
import 'package:masamune_firebase/masamune_firebase.dart';
export 'package:masamune_mobile/masamune_mobile.dart';
export 'package:masamune_firebase/masamune_firebase.dart';

part 'functions/firestorefunctions.dart';
part 'functions/functionstask.dart';
part 'functions/functionsdocument.dart';
part 'functions/functionscollection.dart';

part 'messaging/firestoremessaging.dart';

part 'dynamiclink/firestoredynamiclink.dart';

part 'crashlytics/firestorecrashlytics.dart';

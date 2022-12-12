// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'src/authentication.dart';
import 'firebase_options.dart';
import 'src/widgets.dart';

import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Meetup',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              highlightColor: Colors.deepPurple,
            ),
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) {
          return const HomePage();
        },
        '/sign-in': ((context) {
          return Scaffold(
            appBar: AppBar(),
            body: SignInScreen(
              actions: [
                ForgotPasswordAction(((context, email) {
                  Navigator.of(context).pushNamed('/forgot-password',
                      arguments: {'email': email});
                })),
                AuthStateChangeAction(((context, state) {
                  if (state is SignedIn || state is UserCreated) {
                    var user = (state is SignedIn)
                        ? state.user
                        : (state as UserCreated).credential.user;
                    if (user == null) {
                      return;
                    }
                    if (state is UserCreated) {
                      user.updateDisplayName(user.email!.split('@')[0]);
                    }
                    if (!user.emailVerified) {
                      user.sendEmailVerification();
                      const snackBar = SnackBar(
                          content: Text(
                              'Please check your email to verify your email address'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                    Navigator.of(context).pushReplacementNamed('/home');
                  }
                })),
              ],
            ),
          );
        }),
        '/forgot-password': ((context) {
          final arguments = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          return ForgotPasswordScreen(
            email: arguments?['email'] as String,
            headerMaxExtent: 200,
          );
        }),
        '/profile': ((context) {
          return ProfileScreen(
            providers: [],
            actions: [
              SignedOutAction(
                ((context) {
                  Navigator.of(context).pushReplacementNamed('/home');
                }),
              ),
            ],
          );
        })
      },
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  int _attendees = 0;
  int get attendees => _attendees;

  Attending _attending = Attending.unknown;
  Attending get attending => _attending;
  set attending(Attending attending) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    if (attending == Attending.yes) {
      userDoc.set(<String, dynamic>{'attending': true});
    } else {
      userDoc.set(<String, dynamic>{'attending': false});
    }
  }

  StreamSubscription<DocumentSnapshot>? _attendingSubscription;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _attendees = snapshot.docs.length;
      notifyListeners();
    });

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (var document in snapshot.docs) {
            _guestBookMessages.add(GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String));
          }
          notifyListeners();
        });

        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.data() != null) {
            if (snapshot.data()!['attending'] as bool) {
              _attending = Attending.yes;
            } else {
              _attending = Attending.no;
            }
          } else {
            _attending = Attending.unknown;
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }

    return FirebaseFirestore.instance
        .collection('guestbook')
        .add(<String, dynamic>{
      'text': message,
      // 'timestamp': DateTime.now().microsecondsSinceEpoch,
      'timestamp': Timestamp.now(),
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }
}

class GuestBook extends StatefulWidget {
  const GuestBook(
      {required this.addMessage, required this.messages, super.key});
  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;

  @override
  State<GuestBook> createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Leave a Message'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your Message';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                StyledButton(
                    child: Row(children: const [
                      Icon(Icons.send),
                      SizedBox(
                        width: 4,
                      ),
                      Text('Send')
                    ]),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await widget.addMessage(_controller.text);
                        _controller.clear();
                      }
                    })
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        for (var message in widget.messages)
          Paragraph('${message.name}: ${message.message}'),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}

class GuestBookMessage {
  GuestBookMessage({required this.name, required this.message});

  final String name;
  final String message;
}

enum Attending { yes, no, unknown }

class YesNoSelection extends StatelessWidget {
  final Attending state;
  final void Function(Attending attending) onSelection;

  const YesNoSelection(
      {required this.state, required this.onSelection, super.key});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case Attending.yes:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ElevatedButton(
                  onPressed: () => onSelection(Attending.yes),
                  child: const Text('yes')),
              const SizedBox(width: 8),
              TextButton(
                  onPressed: () => onSelection(Attending.no),
                  child: const Text('No'))
            ],
          ),
        );
      case Attending.no:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              TextButton(
                  onPressed: () => onSelection(Attending.yes),
                  child: const Text('yes')),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () => onSelection(Attending.no),
                  child: const Text('No'))
            ],
          ),
        );
      case Attending.unknown:
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              TextButton(
                  onPressed: () => onSelection(Attending.yes),
                  child: const Text('yes')),
              const SizedBox(width: 8),
              TextButton(
                  onPressed: () => onSelection(Attending.no),
                  child: const Text('No'))
            ],
          ),
        );
    }
  }
}

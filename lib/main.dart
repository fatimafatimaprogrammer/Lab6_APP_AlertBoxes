class AppModel extends ChangeNotifier {
  String _currentUser;
  String get currentUser => _currentUser;
  set currentUser(String currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }}

class UserModel extends ChangeNotifier {
  List<String> _userPosts;
  List<String> get userPosts => _userPosts;
  set userPosts(List<String> userPosts) {
    _userPosts = userPosts;
    notifyListeners();
  } }

Service Tier
class UserService {
  Future<bool> login(String user, String pass) async {
    // Fake a network service call, and return true
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  Future<List<String>> getPosts(String user) async {
    // Fake a service call, and return some posts
    await Future.delayed(Duration(seconds: 1));
    return List.generate(50, (index) => "Item ${Random().nextInt(999)}}");
  }
}
Controller Tier
uildContext _mainContext;
void init(BuildContext c) => _mainContext = c;

// Provide quick lookup methods for all the top-level models and services.
class BaseCommand {
  // Models
  UserModel userModel = _mainContext.read();
  AppModel appModel = _mainContext.read();
  // Services
  UserService userService = _mainContext.read();
}
View Tier

import controller.dart;
import service.dart;
import model.dart;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext _) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => AppModel()),
        ChangeNotifierProvider(create: (c) => UserModel()),
        Provider(create: (c) => UserService()),
      ],
      child: Builder(builder: (context) {
        Commands.init(context);
        return MaterialApp(home: AppScaffold());
      }),
    );
  }
}
class AppScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Bind to AppModel.currentUser
    String currentUser = context.select<AppModel, String>((value) => value.currentUser);

    // Return the current view, based on the currentUser value:
    return Scaffold(
      body: currentUser != null ? HomePage() : LoginPage(),
    );
  }
}
class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  void _handleRefreshPressed() async {
    // Disable the RefreshBtn while the Command is running
    setState(() => _isLoading = true);
    // Run command
    await RefreshPostsCommand().run(context.read<AppModel>().currentUser);
    // Re-enbable refresh btn when command is done
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Bind to UserModel.userPosts
    var users = context.select<UserModel, List<String>>((value) => value.userPosts);
    // Disable btn by removing listener when we're loading.
    VoidCallback btnHandler = _isLoading ? null : _handleRefreshPressed;
    // Render list of widgets
    var listWidgets = users.map((post) => Text(post)).toList();
    return Scaffold(
      body: Column(
        children: [
          Flexible(child: ListView(children: listWidgets)),
          FlatButton(child: Text("REFRESH"), onPressed: btnHandler),
        ],
      ),);}}


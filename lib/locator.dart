import 'package:cat_gallery/data/cat_provider.dart';
import 'package:cat_gallery/data/user_provider.dart';
import 'package:cat_gallery/store/cat_store.dart';
import 'package:cat_gallery/store/user_store.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocatorForProviders() {
  locator.registerSingleton(CatProvider());
  locator.registerSingleton(UserProvider());
}

Future<void> setupLocatorForStores() async {
  locator.registerSingletonAsync<UserStore>(() async {
    final store = UserStore();
    await store.init();
    return store;
  });

  locator.registerSingletonAsync<CatStore>(() async {
    final store = CatStore();
    await store.init();
    return store;
  });
}

Future<void> setupLocator(String docDir) async {
  await setupLocatorForStores();
  setupLocatorForProviders();
}
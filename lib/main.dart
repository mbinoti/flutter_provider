import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const ProviderShowcaseApp());
}

class ProviderShowcaseApp extends StatelessWidget {
  const ProviderShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Showcase',
      theme: ThemeData(useMaterial3: true),
      home: const HomeMenu(),
    );
  }
}

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DemoItem>[
      _DemoItem('Provider<T> (valor simples)', const DemoProviderSimple()),
      _DemoItem('ChangeNotifierProvider (estado mutável)',
          const DemoChangeNotifier()),
      _DemoItem('FutureProvider', const DemoFutureProvider()),
      _DemoItem('StreamProvider (Stream)', const DemoStreamProvider()),
      _DemoItem('ChangeNotifierProxyProvider (proxy + mutável)',
          const DemoChangeNotifierProxyProvider()),
      _DemoItem('MultiProvider (combinar vários)', const DemoMultiProvider()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Showcase')),
      body: ListView.separated(
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.title),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => item.page),
                );
              },
            );
          },
          separatorBuilder: (_, __) {
            return const Divider(
                // height: 1,
                );
          },
          itemCount: items.length),
    );
  }
}

class _DemoItem {
  final String title;
  final Widget page;

  _DemoItem(this.title, this.page);
}

//=============================================
// 1) Provider<T> - valor simples
//=============================================
/// `Provider<T>` e como um recado no mural: todo mundo aqui dentro pode ler.
/// Esta tela so mostra um valor simples para os filhos usarem.
class DemoProviderSimple extends StatelessWidget {
  const DemoProviderSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<String>(
      create: (_) => 'Olá, Provider!',
      child: Builder(builder: (context) {
        final message = context.watch<String>();
        return Scaffold(
          appBar: AppBar(title: const Text('Provider<T>')),
          body: Center(
            child: Text(message,
                style: Theme.of(context).textTheme.headlineMedium),
          ),
        );
      }),
    );
  }
}

//=============================================
// 2? ChangeNotifierProvider - estado mutável
//=============================================

/// Modelo de estado mutavel usado pelo ChangeNotifierProvider.
class Counter extends ChangeNotifier {
  int value = 0;

  void increment() {
    value++;
    notifyListeners();
  }
}

/// ChangeNotifierProvider e como um placar que avisa quando muda.
/// Quando o numero muda, ele grita e a tela atualiza sozinha.
class DemoChangeNotifier extends StatelessWidget {
  const DemoChangeNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Counter>(
      create: (_) => Counter(),
      child: Builder(builder: (context) {
        final counter = context.watch<Counter>();
        return Scaffold(
          appBar: AppBar(title: const Text('ChangeNotifierProvider')),
          body: Center(
            child: Text('Counter: ${counter.value}',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<Counter>().increment(),
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }
}

//=============================================
// 3? FutureProvider - assincrono (future)
//=============================================

Future<String> fetchMessage() async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Dados do Future ✅';
}

/// FutureProvider e como pedir algo e esperar chegar.
/// Enquanto espera, aparece "Carregando"; quando chega, mostra o resultado.
class DemoFutureProvider extends StatelessWidget {
  const DemoFutureProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureProvider<String>(
      create: (_) => fetchMessage(),
      initialData: 'Carregando...',
      child: Builder(builder: (context) {
        final message = context.watch<String>();
        return Scaffold(
          appBar: AppBar(title: const Text('FutureProvider')),
          body: Center(
            child: Text(message,
                style: Theme.of(context).textTheme.headlineMedium),
          ),
        );
      }),
    );
  }
}

//=============================================
// 4) StreamProvider — assíncrono (Stream)
// =======================================================

Stream<int> counterStream() async* {
  int i = 0;
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    yield i++;
  }
}

/// StreamProvider e como uma torneira de dados: pinga o tempo todo.
/// A tela recebe numeros novos sem parar.
class DemoStreamProvider extends StatelessWidget {
  const DemoStreamProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<int?>(
      create: (_) => counterStream(),
      initialData: 0,
      child: Builder(builder: (context) {
        final counter = context.watch<int>();
        return Scaffold(
          appBar: AppBar(title: const Text('StreamProvider')),
          body: Center(
            child: Text('Counter: $counter',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
        );
      }),
    );
  }
}

// =======================================================
// 5) ProxyProvider — derivar valor a partir de outros
// =======================================================

class Config {
  final String apiBaseUrl;
  Config(this.apiBaseUrl);
}

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);
}

/// ProxyProvider e como montar algo usando outra coisa como base.
/// Aqui o ApiClient nasce usando o Config que ja existe.
class DemoProxyProvider extends StatelessWidget {
  const DemoProxyProvider({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Config>(create: (_) => Config('https://api.example.com')),
        ProxyProvider<Config, ApiClient>(
          update: (_, config, __) => ApiClient(config.apiBaseUrl),
        ),
      ],
      child: Builder(builder: (context) {
        final api = context.watch<ApiClient>();
        return Scaffold(
          appBar: AppBar(title: const Text('ProxyProvider')),
          body: Center(
            child: Text('API Base URL: ${api.baseUrl}',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
        );
      }),
    );
  }
}

// =======================================================
// 6) ChangeNotifierProxyProvider — proxy + estado mutável
// =======================================================

class User extends ChangeNotifier {
  String name = 'Marcos';

  void setName(String value) {
    name = value;
    notifyListeners();
  }
}

class GreetingModel extends ChangeNotifier {
  String greeting = '';

  void updateFromUser(User user) {
    greeting = 'Olá, ${user.name}!';
    notifyListeners();
  }
}

class DemoChangeNotifierProxyProvider extends StatelessWidget {
  const DemoChangeNotifierProxyProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<User>(create: (_) => User()),
        ChangeNotifierProxyProvider<User, GreetingModel>(
          create: (_) => GreetingModel(),
          update: (_, user, greetingModel) {
            final model = greetingModel ?? GreetingModel();
            model.updateFromUser(user);
            return model;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final greeting = context.watch<GreetingModel>().greeting;
          final userName = context.read<User>().name;
          return Scaffold(
            appBar: AppBar(title: const Text('ChangeNotifierProxyProvider')),
            body: Center(
              child: Column(
                children: [
                  Text(greeting,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(
                    'Nome atual: $userName',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () =>
                        context.read<User>().setName('Flutter Dev'),
                    child: const Text('Mudar nome'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =======================================================
// 7) MultiProvider — combinar vários providers
// =======================================================

class DemoMultiProvider extends StatelessWidget {
  const DemoMultiProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<String>(create: (_) => 'Olá do usermem!'),
        ChangeNotifierProvider<Counter>(create: (_) => Counter()),
      ],
      child: Builder(builder: (context) {
        final message = context.watch<String>();
        final counter = context.watch<Counter>();
        return Scaffold(
          appBar: AppBar(title: const Text('MultiProvider')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                Text('Counter: ${counter.value}',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<Counter>().increment(),
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }
}

# Provider Showcase (Flutter + provider)

Aplicativo Flutter que demonstra, em telas simples, como usar o pacote `provider` para gerenciar estado e dependências.

## O que ele mostra
- Provider<T> para compartilhar valores imutáveis.
- ChangeNotifierProvider para estado mutável com notificação de ouvintes.
- FutureProvider para carregar dados assíncronos (Future) com estado inicial.
- StreamProvider para streams contínuas (contador em tempo real).
- ProxyProvider e ChangeNotifierProxyProvider para derivar dependências e manter estado reativo.
- MultiProvider para combinar múltiplos providers em uma árvore.

## Como executar
1) Instale dependências: `flutter pub get`
2) Rode no emulador/dispositivo: `flutter run`

## Estrutura
- [lib/main.dart](lib/main.dart): navegação e exemplos de cada provider.

## Dependência principal
- provider (gerenciamento de estado para Flutter)

## Testes
- `flutter test`

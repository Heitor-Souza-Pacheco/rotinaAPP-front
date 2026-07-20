# RotinaApp 🌱

Aplicativo de **rotina e hábitos** para bem-estar, construído em Flutter e
integrado ao backend Spring Boot (`appRotina-API`).

## Funcionalidades

- **Autenticação** (registro e login) com JWT armazenado de forma segura.
- **Hoje**: hábitos do dia com anel de progresso, seletor de semana e
  marcação de conclusão com atualização otimista.
- **Meus hábitos**: criar, editar, pausar/reativar e excluir hábitos.
- **Estatísticas**: sequência atual (streak), maior sequência, total de dias
  concluídos e taxas de conclusão (7 e 30 dias) com gráficos.
- **Perfil**: fuso horário, horário de reset diário e lembrete diário; logout.

## Arquitetura

```
lib/
├── core/          Configuração, tema, cliente HTTP, armazenamento de token
├── models/        Modelos de domínio (Usuario, Habito, HabitoDoDia, Estatistica)
├── services/      Serviços que consomem a API (auth, habito, perfil)
├── providers/     Estado da aplicação (ChangeNotifier + provider)
├── screens/       Telas da aplicação
├── widgets/       Componentes reutilizáveis
└── main.dart      Wiring de dependências e AuthGate
```

- **Estado**: `provider` (`ChangeNotifier`).
- **Rede**: `http`, com injeção automática do token e tratamento de erros.
- **Sessão**: token JWT em `flutter_secure_storage`.

## Configuração da API

A URL base fica em [lib/core/config.dart](lib/core/config.dart):

```dart
static const String apiBaseUrl =
    'https://approtina-api-production.up.railway.app';
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Endpoints consumidos

| Método | Rota                                   | Uso                         |
|--------|----------------------------------------|-----------------------------|
| POST   | `/api/auth/registrar`                  | Criar conta                 |
| POST   | `/api/auth/login`                      | Entrar                      |
| GET    | `/api/habitos/hoje?data=YYYY-MM-DD`    | Hábitos do dia              |
| GET    | `/api/habitos`                         | Todos os hábitos            |
| POST   | `/api/habitos`                         | Criar hábito                |
| PUT    | `/api/habitos/{id}`                     | Editar/pausar hábito        |
| DELETE | `/api/habitos/{id}`                     | Excluir hábito              |
| POST   | `/api/habitos/{id}/concluir?data=...`  | Marcar concluído            |
| DELETE | `/api/habitos/{id}/concluir?data=...`  | Desmarcar                   |
| GET    | `/api/habitos/{id}/estatisticas`       | Estatísticas do hábito      |
| GET    | `/api/usuarios/perfil`                 | Ver perfil                  |
| PUT    | `/api/usuarios/perfil`                 | Atualizar perfil            |
</content>

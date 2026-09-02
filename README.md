<p align="center">
  <img src="./assets/rotinaappbanner.png" width="100%" alt="RotinaApp">
</p>

<p align="center">
  <strong>Aplicativo mobile para organização de rotina e hábitos, desenvolvido em Flutter.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/Provider-764ABC?style=for-the-badge">
  <img src="https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white">
  <img src="https://img.shields.io/badge/REST%20API-005571?style=for-the-badge">
</p>

---

# 🌱 Sobre o projeto

O **RotinaApp** é um aplicativo mobile desenvolvido em **Flutter** com o objetivo de auxiliar usuários na organização de sua rotina e no acompanhamento de hábitos.

A aplicação permite criar e gerenciar hábitos, acompanhar o progresso diário, definir lembretes e visualizar estatísticas de consistência.

O aplicativo é integrado ao backend **appRotina-API**, desenvolvido em Java e Spring Boot, responsável pelo processamento dos dados e regras de negócio.

---

# ✨ Funcionalidades

## 🔐 Autenticação

- Cadastro de usuários.
- Login.
- Autenticação utilizando JWT.
- Armazenamento seguro do token.
- Gerenciamento de sessão.
- Logout.

---

## 📅 Hoje

A tela principal apresenta os hábitos programados para o dia.

- 📋 Lista de hábitos do dia.
- ⭕ Anel de progresso.
- 📆 Seletor de semana.
- ✅ Marcação de hábitos concluídos.
- ⚡ Atualização otimista da interface.
- 📊 Acompanhamento do progresso diário.

---

## 📝 Meus hábitos

Área destinada ao gerenciamento dos hábitos do usuário.

- ➕ Criar hábitos.
- ✏️ Editar hábitos.
- ⏸️ Pausar hábitos.
- ▶️ Reativar hábitos.
- 🗑️ Excluir hábitos.

---

## 📊 Estatísticas

O aplicativo permite acompanhar a evolução e consistência do usuário.

Entre os dados apresentados estão:

- 🔥 Streak atual.
- 🏆 Maior sequência.
- 📅 Total de dias concluídos.
- 📈 Taxa de conclusão dos últimos 7 dias.
- 📈 Taxa de conclusão dos últimos 30 dias.
- 📊 Gráficos de acompanhamento.

---

## 👤 Perfil

O usuário pode configurar informações relacionadas à sua rotina:

- 🌎 Fuso horário.
- 🌙 Horário de reset diário.
- 🔔 Lembrete diário.
- 🚪 Logout.

---

# 🔥 Sistema de Streak

Um dos principais recursos do RotinaApp é o acompanhamento da **sequência de dias em que o usuário mantém seus hábitos**.

```text
        🔥 STREAK

    SEG   ✅
    TER   ✅
    QUA   ✅
    QUI   ✅
    SEX   ✅
    SÁB   ❌

       🔥 5 dias
      de sequência
```

O objetivo é tornar a consistência visível e incentivar a manutenção dos hábitos ao longo do tempo.

---

# 🏗️ Arquitetura

O projeto utiliza uma arquitetura organizada por responsabilidades:

```text
lib/
│
├── core/
│   ├── Configuração
│   ├── Tema
│   ├── Cliente HTTP
│   └── Armazenamento do token
│
├── models/
│   ├── Usuario
│   ├── Habito
│   ├── HabitoDoDia
│   └── Estatistica
│
├── services/
│   ├── Auth
│   ├── Habito
│   └── Perfil
│
├── providers/
│   └── Gerenciamento de estado
│
├── screens/
│   └── Telas da aplicação
│
├── widgets/
│   └── Componentes reutilizáveis
│
└── main.dart
```

---

# ⚙️ Tecnologias

| Tecnologia | Utilização |
|---|---|
| 🦋 Flutter | Desenvolvimento do aplicativo |
| 🎯 Dart | Linguagem principal |
| 🔄 Provider | Gerenciamento de estado |
| 🌐 HTTP | Comunicação com a API |
| 🔐 JWT | Autenticação |
| 🔒 flutter_secure_storage | Armazenamento seguro do token |
| ⚙️ REST API | Comunicação com o backend |

---

# 🔗 Integração com o Backend

O RotinaApp consome a API **appRotina-API**, desenvolvida utilizando Java e Spring Boot.

```text
┌──────────────────────┐
│      📱 RotinaApp    │
│                      │
│ Flutter + Dart       │
└──────────┬───────────┘
           │
           │ HTTP / REST
           ▼
┌──────────────────────┐
│    ⚙️ appRotina API  │
│                      │
│ Java + Spring Boot   │
└──────────┬───────────┘
           │
           ▼
        Banco de dados
```

### ⚙️ API utilizada

**Repositório:**

[appRotina-API](https://github.com/Heitor-Souza-Pacheco/appRotina-API)

---

# 📡 Endpoints consumidos

## 🔐 Autenticação

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/api/auth/registrar` | Criar conta |
| `POST` | `/api/auth/login` | Realizar login |

---

## 📝 Hábitos

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/api/habitos/hoje?data=YYYY-MM-DD` | Buscar hábitos do dia |
| `GET` | `/api/habitos` | Listar hábitos |
| `POST` | `/api/habitos` | Criar hábito |
| `PUT` | `/api/habitos/{id}` | Editar ou pausar hábito |
| `DELETE` | `/api/habitos/{id}` | Excluir hábito |
| `POST` | `/api/habitos/{id}/concluir?data=...` | Marcar hábito como concluído |
| `DELETE` | `/api/habitos/{id}/concluir?data=...` | Desmarcar conclusão |
| `GET` | `/api/habitos/{id}/estatisticas` | Consultar estatísticas |

---

## 👤 Perfil

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/api/usuarios/perfil` | Consultar perfil |
| `PUT` | `/api/usuarios/perfil` | Atualizar perfil |

---

# 🌐 Configuração da API

A URL base da API está centralizada em:

```text
lib/core/config.dart
```

Atualmente:

```dart
static const String apiBaseUrl =
    'https://approtina-api-production.up.railway.app';
```

Caso seja necessário utilizar outro ambiente, altere a URL nesse arquivo.

---

# 🚀 Como executar

## 📋 Pré-requisitos

Antes de executar o projeto, certifique-se de possuir:

- Flutter instalado.
- Dart SDK.
- Android Studio ou ambiente equivalente.
- Emulador Android ou dispositivo físico configurado.

---

## 1. Clone o repositório

```bash
git clone https://github.com/Heitor-Souza-Pacheco/rotinaAPP-front.git
```

Entre na pasta:

```bash
cd rotinaAPP-front
```

---

## 2. Instale as dependências

```bash
flutter pub get
```

---

## 3. Execute o aplicativo

```bash
flutter run
```

O Flutter irá executar o aplicativo no dispositivo ou emulador selecionado.

---

# 📂 Estrutura do projeto

```text
rotinaAPP-front/
│
├── assets/
│
├── lib/
│   ├── core/
│   ├── models/
│   ├── services/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── main.dart
│
├── android/
├── ios/
├── test/
├── pubspec.yaml
└── README.md
```

---

# 🧠 Conceitos praticados

Durante o desenvolvimento foram trabalhados conceitos importantes de desenvolvimento mobile:

- 📱 Desenvolvimento de aplicativos com Flutter.
- 🎯 Programação em Dart.
- 🔄 Gerenciamento de estado com Provider.
- 🌐 Consumo de APIs REST.
- 🔐 Autenticação utilizando JWT.
- 🔒 Armazenamento seguro de credenciais.
- 📡 Comunicação HTTP.
- 🧩 Componentização de widgets.
- 🏗️ Organização por responsabilidades.
- 📊 Manipulação e apresentação de dados.
- 📅 Manipulação de datas e hábitos.
- 🔥 Implementação de lógica de Streak.

---

# 📚 Aprendizados

O desenvolvimento do RotinaApp proporcionou experiência prática na construção de uma aplicação mobile integrada a um backend.

Entre os principais aprendizados estão:

- Desenvolvimento de interfaces mobile com Flutter.
- Gerenciamento de estado utilizando Provider.
- Integração de aplicativos com APIs REST.
- Implementação de autenticação JWT.
- Armazenamento seguro de tokens.
- Organização de aplicações Flutter.
- Criação de componentes reutilizáveis.
- Manipulação de datas e informações de rotina.
- Desenvolvimento de regras relacionadas a hábitos e consistência.

---

# 🔮 Próximos passos

Possíveis evoluções para o projeto:

- [ ] Melhorar o sistema de notificações.
- [ ] Adicionar diferentes tipos de lembretes.
- [ ] Melhorar os gráficos de estatísticas.
- [ ] Adicionar temas personalizados.
- [ ] Adicionar modo escuro.
- [ ] Melhorar animações e microinterações.
- [ ] Adicionar sincronização offline.
- [ ] Implementar testes automatizados.
- [ ] Publicar o aplicativo em uma loja de aplicativos.

---

# 🔗 Projeto relacionado

O RotinaApp faz parte de um projeto composto por aplicativo mobile e backend:

### 📱 Frontend

**rotinaAPP-front**

Flutter + Dart

### ⚙️ Backend

**appRotina-API**

Java + Spring Boot

---

# 👨‍💻 Desenvolvedor

## Heitor Souza Pacheco

Estudante de Ensino Médio Técnico em Informática e desenvolvedor interessado em **desenvolvimento de software, Java, Spring Boot, Flutter e APIs REST**.

<p align="center">
  <a href="https://github.com/Heitor-Souza-Pacheco">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white">
  </a>
  <a href="https://linkedin.com/in/heitor-souza-pacheco">
    <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white">
  </a>
</p>

---

<p align="center">
  ⭐ Se você gostou do projeto, considere deixar uma estrela!
</p>

# Splitfoot

Splitfoot is a Flutter application for organizing amateur football players and generating balanced teams.

[English](#english) | [Português](#português) | [Open the Web app](https://splitfoot.netlify.app/)

## English

### About the project

Splitfoot helps amateur football organizers manage groups and players, select the participants in a match, and generate balanced teams using different criteria. The application is local-first, works offline after installation or loading, and does not require an account.

**Live Web version:** [https://splitfoot.netlify.app/](https://splitfoot.netlify.app/)

### Main features

- Create, edit, and delete player groups.
- Add, edit, search, filter, and delete players.
- Filter players by group, sport, and position.
- Record attack, defense, and stamina attributes from 0 to 99.
- Assign a sport and position to each player.
- Calculate each player's overall automatically as the integer average of attack, defense, and stamina.
- Support Futsal, 7-a-side football (`Fut7`), and 11-a-side football (`Fut11`).
- Set up a match by choosing the group, sport, size of each team, balance criterion, and participants.
- Generate up to five unique team divisions.
- Compare generated teams by average overall and total attack, defense, and stamina.
- Recalculate the same match with another balance criterion from the results screen.
- View rankings by overall, attack, defense, stamina, and goalkeepers, with group and sport filters.
- Copy results to the clipboard on the Web and share them through the operating system on Android.
- Store all application data locally with Hive.

### How team balancing works

The selected players must exactly fill Team A and Team B. Splitfoot evaluates valid divisions and sorts them from the smallest to the largest difference according to the chosen criterion:

1. **Average overall**: minimizes the absolute difference between the teams' average overall values.
2. **Attribute totals**: minimizes the sum of the absolute differences in total attack, defense, and stamina.
3. **Position distribution**: distributes each position proportionally between the teams, then prioritizes the division with the smallest difference in total overall.

The overall value is calculated as:

```text
overall = floor((attack + defense + stamina) / 3)
```

For selections with a manageable number of combinations, the service evaluates every valid division. For larger selections, it uses a bounded deterministic heuristic to keep generation responsive. Mirrored duplicate divisions are removed when the teams have the same size, and up to five of the best results are returned.

### Technologies

- **Flutter** and **Dart** for the application and interface.
- **Material Design** widgets for the UI.
- **Hive** and **hive_flutter** for local persistence.
- **go_router** for navigation.
- **share_plus** for native result sharing.
- **url_launcher** for external links.
- **build_runner** and **hive_generator** for Hive adapter generation.
- **flutter_test** for widget, balancing, and result-formatting tests.

### Project structure

The source code is organized by responsibility:

```text
lib/
├── app/                    # App configuration, routes, and theme
├── core/                   # Enums, utilities, and performance helpers
├── data/
│   ├── datasources/        # Hive-backed local data access
│   ├── models/             # Player and group models and Hive adapters
│   └── services/           # Local data migration
├── domain/
│   ├── entities/           # Match requests and generated results
│   └── services/           # Team balancing, rankings, and position weights
├── presentation/pages/     # Application screens
├── widgets/                # Shared widgets and forms
└── main.dart               # Hive initialization and app entry point

assets/images/              # Application images
test/                       # Automated tests
android/                    # Android platform project
web/                        # Web platform files
```

### Run locally

#### Requirements

- Flutter on the stable channel with a Dart SDK compatible with `^3.8.1`.
- Chrome for the Web target, or an Android device/emulator for Android.

Clone the repository and install the dependencies:

```bash
git clone https://github.com/jalobler7/divide_time-mobile.git
cd divide_time-mobile
flutter pub get
```

Run on the Web:

```bash
flutter run -d chrome
```

Run on Android:

```bash
flutter devices
flutter run -d <device-id>
```

### Build for the Web

```bash
flutter build web --release
```

The generated files are placed in `build/web/`. The repository's `netlify.toml` redirects all routes to `index.html`, which supports direct access to routes when deployed on Netlify.

The currently deployed version is available at [splitfoot.netlify.app](https://splitfoot.netlify.app/).

### Build the Android APK

```bash
flutter build apk --release
```

The release APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Data storage

Hive stores players and groups in the local `players` and `team_groups` boxes. Data remains only on the current device or browser profile. Splitfoot has no account system, backend, cloud backup, or synchronization between devices; clearing the application's local data may therefore remove the saved information.

Deleting a group also deletes its associated players after confirmation. A startup migration assigns legacy players without a group to the default **Meus atletas** group.

### Supported platforms

- Android
- Web

## Português

### Sobre o projeto

O Splitfoot ajuda organizadores de futebol amador a gerenciar grupos e jogadores, selecionar os participantes de uma partida e gerar times equilibrados por diferentes critérios. O aplicativo prioriza dados locais, funciona offline após a instalação ou carregamento e não exige conta.

**Versão Web online:** [https://splitfoot.netlify.app/](https://splitfoot.netlify.app/)

### Principais funcionalidades

- Criação, edição e exclusão de grupos de jogadores.
- Cadastro, edição, busca, filtros e exclusão de jogadores.
- Filtros de jogadores por grupo, esporte e posição.
- Atributos de ataque, defesa e fôlego entre 0 e 99.
- Definição de esporte e posição para cada jogador.
- Cálculo automático do overall pela média inteira de ataque, defesa e fôlego.
- Suporte a Futsal, futebol de 7 (`Fut7`) e futebol de 11 (`Fut11`).
- Montagem de partidas com escolha de grupo, esporte, tamanho de cada time, critério de equilíbrio e participantes.
- Geração de até cinco divisões únicas de times.
- Comparação dos times pelo overall médio e pelos totais de ataque, defesa e fôlego.
- Recálculo da mesma partida com outro critério de equilíbrio pela tela de resultados.
- Rankings por overall, ataque, defesa, fôlego e goleiros, com filtros de grupo e esporte.
- Cópia dos resultados para a área de transferência na Web e compartilhamento pelo sistema operacional no Android.
- Armazenamento local de todos os dados com Hive.

### Como funciona o balanceamento dos times

Os jogadores selecionados devem preencher exatamente o Time A e o Time B. O Splitfoot avalia as divisões válidas e as ordena da menor para a maior diferença conforme o critério escolhido:

1. **Overall médio**: minimiza a diferença absoluta entre os overalls médios dos times.
2. **Soma dos atributos**: minimiza a soma das diferenças absolutas dos totais de ataque, defesa e fôlego.
3. **Distribuição por posições**: distribui cada posição proporcionalmente entre os times e depois prioriza a divisão com a menor diferença de overall total.

O overall é calculado assim:

```text
overall = floor((ataque + defesa + fôlego) / 3)
```

Quando a quantidade de combinações é administrável, o serviço avalia todas as divisões válidas. Em seleções maiores, utiliza uma heurística determinística e limitada para manter a geração responsiva. Divisões duplicadas por simples inversão dos times são removidas quando os tamanhos são iguais, e até cinco dos melhores resultados são retornados.

### Tecnologias utilizadas

- **Flutter** e **Dart** para a aplicação e a interface.
- Widgets do **Material Design** para a UI.
- **Hive** e **hive_flutter** para persistência local.
- **go_router** para navegação.
- **share_plus** para compartilhamento nativo dos resultados.
- **url_launcher** para links externos.
- **build_runner** e **hive_generator** para geração dos adaptadores do Hive.
- **flutter_test** para testes de widgets, balanceamento e formatação dos resultados.

### Estrutura do projeto

O código-fonte está organizado por responsabilidade:

```text
lib/
├── app/                    # Configuração, rotas e tema do aplicativo
├── core/                   # Enums, utilitários e recursos de desempenho
├── data/
│   ├── datasources/        # Acesso local aos dados com Hive
│   ├── models/             # Modelos de jogador e grupo e adaptadores Hive
│   └── services/           # Migração de dados locais
├── domain/
│   ├── entities/           # Requisições de partida e resultados gerados
│   └── services/           # Balanceamento, rankings e pesos de posições
├── presentation/pages/     # Telas da aplicação
├── widgets/                # Widgets e formulários compartilhados
└── main.dart               # Inicialização do Hive e entrada da aplicação

assets/images/              # Imagens da aplicação
test/                       # Testes automatizados
android/                    # Projeto da plataforma Android
web/                        # Arquivos da plataforma Web
```

### Como executar localmente

#### Requisitos

- Flutter no canal estável com uma versão do Dart compatível com `^3.8.1`.
- Chrome para executar na Web ou um dispositivo/emulador Android para Android.

Clone o repositório e instale as dependências:

```bash
git clone https://github.com/jalobler7/divide_time-mobile.git
cd divide_time-mobile
flutter pub get
```

Execute na Web:

```bash
flutter run -d chrome
```

Execute no Android:

```bash
flutter devices
flutter run -d <device-id>
```

### Como gerar o build Web

```bash
flutter build web --release
```

Os arquivos gerados ficam em `build/web/`. O `netlify.toml` do repositório redireciona todas as rotas para `index.html`, permitindo acessar rotas diretamente quando a aplicação é publicada na Netlify.

A versão atualmente publicada está disponível em [splitfoot.netlify.app](https://splitfoot.netlify.app/).

### Como gerar o APK Android

```bash
flutter build apk --release
```

O APK de release é gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Armazenamento de dados

O Hive armazena jogadores e grupos localmente nas boxes `players` e `team_groups`. Os dados permanecem somente no dispositivo ou perfil de navegador atual. O Splitfoot não possui sistema de contas, backend, backup em nuvem ou sincronização entre dispositivos; limpar os dados locais da aplicação pode, portanto, remover as informações salvas.

A exclusão de um grupo também remove seus jogadores associados após confirmação. Uma migração executada na inicialização associa jogadores antigos sem grupo ao grupo padrão **Meus atletas**.

### Plataformas suportadas

- Android
- Web

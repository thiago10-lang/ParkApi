<div align="center">

# 🅿️ ParkingAPI

**Sistema de gerenciamento de estacionamento com API REST, aplicativo Flutter, solicitação de vagas com QR Code e painel administrativo.**

![Java](https://img.shields.io/badge/Backend-Java%2017-orange?style=for-the-badge&logo=openjdk)
![Spring Boot](https://img.shields.io/badge/Framework-Spring%20Boot-6DB33F?style=for-the-badge&logo=springboot)
![H2](https://img.shields.io/badge/Database-H2-1021FF?style=for-the-badge)
![Flutter](https://img.shields.io/badge/App-Flutter-02569B?style=for-the-badge&logo=flutter)

</div>

---

## 🖼 Sobre

O **ParkingAPI** é um sistema de gerenciamento de estacionamento desenvolvido como parte do Projeto Semestral do curso de Análise e Desenvolvimento de Sistemas — IFSP.

O motorista chega ao estacionamento, solicita a vaga pelo aplicativo e recebe um **QR Code** com os dados do ticket. Na saída, o atendente lê o QR Code, o sistema calcula o valor e libera a vaga. O administrador acompanha tudo por um painel com indicadores em tempo real.

---

## 🚀 Funcionalidades

### 🚗 Motorista (perfil CLIENTE)

- Cadastro e login com autenticação JWT
- Solicitação de vaga com formulário curto: nome e CPF apenas na primeira vez, depois somente placa, marca, modelo e cor
- **Mapa de vagas** na solicitação: o motorista escolhe a vaga que quer ou deixa o sistema escolher
- **QR Code** do ticket com recibo, vaga, placa, nome, CPF mascarado e horário de entrada
- Aba **Minha vaga** com ticket, permanência e valor estimado atualizado em tempo real
- Aba **Histórico** com todas as visitas, total pago e relatório em PDF
- Aceita placas no padrão antigo (`ABC-1234`) e Mercosul (`ABC1D23`)
- Bloqueio de duas vagas simultâneas para o mesmo cliente ou a mesma placa
- **Minha conta**: dados do usuário e alteração de senha

### 🔐 Administrador (perfil ADMIN)

- **Dashboard**: taxa de ocupação, vagas livres e ocupadas, entradas e saídas do dia, faturamento do dia e total, usuários, clientes, gráficos de faturamento e de entradas dos últimos 7 dias, recebimentos por forma de pagamento e últimas movimentações, com atualização automática
- **Vagas**: mapa em grade com status, placa e motorista de cada vaga ocupada, e cadastro de novas vagas
- **No pátio**: veículos estacionados, busca por placa, vaga ou motorista e check-out
- **Ler QR**: leitura do QR Code pela câmera ou digitação do recibo, com check-out e valor final
- **Pagamento na saída**: prévia do valor, escolha entre Pix, cartão ou dinheiro e **QR Code Pix copia e cola** com o valor exato
- **Histórico**: todos os estacionamentos com filtro por placa e período e **exportação para planilha (CSV)**
- **Usuários**: usuários do sistema, clientes cadastrados e promoção de usuários a administrador
- **Configurações**: tabela de preços, programa de fidelidade e chave Pix do estacionamento, com simulação de valores
- **Check-in manual** para clientes que não usaram o aplicativo

### 💰 Tabela de preços

Valores padrão, que o administrador pode alterar na aba **Configurações**:

| Permanência | Valor |
| --- | --- |
| Até 15 minutos | R$ 5,00 |
| Até 1 hora | R$ 9,25 |
| Cada 15 minutos adicionais | R$ 1,75 |
| A cada 10 estacionamentos concluídos | 30% de desconto |

---

## 🛠 Tecnologias Utilizadas

| Camada | Tecnologias |
| --- | --- |
| Backend | Java 17, Spring Boot 3.2, Spring Security + JWT, Spring Data JPA / Hibernate, Bean Validation |
| Banco de dados | H2 em memória (dados recriados a cada inicialização) |
| Documentação da API | Springdoc / Swagger UI |
| Relatórios | JasperReports (PDF) |
| Aplicativo | Flutter + Dart (Web, Android, iOS, Windows), `qr_flutter`, `mobile_scanner`, `printing` |
| Deploy | Vercel (aplicativo web) e Docker (API) |

---

## 📂 Estrutura do Projeto

```text
ParkApi/
├── api/                         API REST em Spring Boot
│   ├── src/main/java/com/mballem/demoparkapi/
│   │   ├── config/              segurança, auditoria e dados iniciais
│   │   ├── entity/              entidades JPA
│   │   ├── jwt/                 autenticação JWT
│   │   ├── repository/          repositórios e projeções
│   │   ├── service/             regras de negócio e dashboard
│   │   └── web/                 controllers, DTOs e tratamento de erros
│   ├── src/main/resources/      configurações, mensagens e relatórios
│   ├── Dockerfile
│   └── pom.xml
├── park_app/                    aplicativo Flutter
│   ├── lib/
│   │   ├── models/              ticket e cálculo de valores
│   │   ├── providers/           estado compartilhado (Provider)
│   │   ├── screens/             boas-vindas, login, cadastro e telas comuns
│   │   ├── screens/cliente/     telas do motorista
│   │   ├── screens/admin/       painel administrativo
│   │   ├── services/            camada de acesso à API, sessão e notificações
│   │   ├── theme/               cores e ThemeData do app
│   │   ├── utils/               formatação e Pix
│   │   └── widgets/             componentes reutilizáveis
│   ├── assets/logo.png          logo exibido no app
│   └── pubspec.yaml
├── scripts/                     build do aplicativo na Vercel
├── vercel.json                  deploy do aplicativo web
├── render.yaml                  deploy da API
└── README.md
```

---

## 📱 Projeto Bimestral 1 (BRADEMO)

### Recursos Flutter

| Requisito | Onde está no app |
| --- | --- |
| RC1 Estrutura de pastas | `park_app/lib` separado em `models/`, `screens/`, `widgets/`, `services/`, `theme/`, `utils/` e `assets/logo.png`, como no exercício 3 da Aula 3 |
| RC2 Rotas e Navegação | `Navigator.push` com `MaterialPageRoute` e `Navigator.pop` (boas-vindas → login/cadastro, histórico → detalhes, início → solicitar vaga, minha conta, relatório) |
| RC3 Passagem de dados | Ida: `DetalheTicketScreen(ticket: ...)` recebe o ticket pelo construtor. Volta: `SolicitarVagaScreen` devolve o `Ticket` criado com `Navigator.pop(context, ticket)` e o check-in manual devolve `true` |
| RC4 Formulário | `Form` com `GlobalKey<FormState>`, `TextFormField` e `validator` em `solicitar_vaga_screen.dart` (também em `perfil_screen.dart` e `configuracoes_tab.dart`) |
| RC5 Responsividade | `MediaQuery.of(context).orientation` em `boas_vindas_screen.dart` (coluna em retrato, linha em paisagem), `MediaQuery` em `admin_shell.dart` (menu lateral ou inferior) e `LayoutBuilder` no `dashboard_tab.dart` |
| RC6 ThemeData | `theme/app_theme.dart`, usado no `MaterialApp` do `main.dart` |
| RC7 Widgets Material | `AppBar` em todas as telas, `NavigationBar` inferior no motorista e no admin, `FloatingActionButton` em `vagas_tab.dart` |

### Telas

| Tela | Arquivo |
| --- | --- |
| 1 Boas-vindas | `screens/boas_vindas_screen.dart`: AppBar, logo, textos e botões Entrar / Criar conta |
| 2 Lista de itens | `screens/cliente/historico_tab.dart`: `ListView` com os estacionamentos do motorista |
| 3 Formulário | `screens/cliente/solicitar_vaga_screen.dart`: campos com validação e botão de envio. Os dados digitados aparecem no console (`debugPrint`) |
| 4 Detalhes | `screens/cliente/detalhe_ticket_screen.dart`: aberto ao tocar em um item do histórico |

## 📲 Projeto Bimestral 2 (BRADEMO)

O documento de projeto (tema, requisitos, casos de uso, protótipos com fluxo de navegação e DER) está em [`docs/projeto/Documento-de-Projeto-ParkAPI.pdf`](docs/projeto/Documento-de-Projeto-ParkAPI.pdf).

### Requisitos funcionais

Cadastro (RF-A) e login (RF-B) são obrigatórios e não entram na contagem.

| RF | Requisito | API | Tela |
| --- | --- | --- | --- |
| RF01 | Consultar vagas e preços | `GET /vagas/disponibilidade`, `GET /tarifas` | Início |
| RF02 | Solicitar vaga (com mapa) | `POST /estacionamentos/solicitar` | Solicitar vaga |
| RF03 | Ver ticket com QR Code | `GET /estacionamentos/ativo` | Minha vaga |
| RF04 | Cancelar solicitação (até 15 min) | `DELETE /estacionamentos/ativo` | Minha vaga |
| RF05 | Histórico, detalhes e relatório PDF | `GET /estacionamentos`, `GET /estacionamentos/relatorio` | Histórico |
| RF06 | Receber notificações | `GET /estacionamentos/ativo` a cada 30 s | Notificação |
| RF07 | Alterar senha | `PATCH /usuarios/{id}` | Minha conta |
| RF08 | Dashboard | `GET /dashboard` | Dashboard |
| RF09 | Gerenciar vagas (criar e remover) | `POST /vagas`, `DELETE /vagas/{codigo}` | Vagas |
| RF10 | Saída e pagamento lendo o QR pela câmera | `PUT /estacionamentos/check-out/{recibo}` | Ler QR |
| RF11 | Histórico geral e exportação CSV | `GET /estacionamentos/todos`, `/exportar` | Histórico |
| RF12 | Tarifas e Pix | `PUT /tarifas` | Configurações |
| RF13 | Perfis de usuários | `PATCH /usuarios/{id}/perfil` | Usuários |
| RF14 | Check-in manual | `POST /estacionamentos/check-in` | Check-in manual |

### Recursos nativos e arquitetura

| Critério | Onde está |
| --- | --- |
| Camada que encapsula a API Web | `lib/services/api_service.dart` (HTTP, token e erros) + `auth_service.dart`, `estacionamento_service.dart`, `vaga_service.dart`, `usuario_service.dart`, `tarifa_service.dart`. As telas não fazem HTTP direto |
| Push notification | `lib/services/notificacao_service.dart` com `flutter_local_notifications`: vaga reservada, solicitação cancelada e saída registrada. Permissão `POST_NOTIFICATIONS` no `AndroidManifest.xml` |
| Recurso extra | Câmera para ler o QR Code do ticket (`mobile_scanner`) na aba Ler QR do administrador |
| Provider | `lib/providers/estacionamento_provider.dart` registrado no `main.dart` com `ChangeNotifierProvider` e lido nas abas do motorista com `context.watch` |

---

## 🔧 Como rodar em qualquer máquina

### 1. Instale os pré-requisitos

| Ferramenta | Versão | Como verificar |
| --- | --- | --- |
| [Git](https://git-scm.com/downloads) | qualquer | `git --version` |
| [JDK](https://adoptium.net/temurin/releases/?version=17) | 17 ou superior | `java -version` |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.x estável (Dart 3.12+) | `flutter --version` |
| Google Chrome | qualquer | necessário para rodar o app no navegador |

> Não é preciso instalar Maven nem banco de dados: o projeto usa o Maven Wrapper (`mvnw`) e o banco H2 em memória.

Depois de instalar o Flutter, rode `flutter doctor` e confirme que o item **Chrome** aparece com ✓.

### 2. Clone o repositório

```bash
git clone https://github.com/thiago10-lang/ParkApi.git
cd ParkApi
```

### 3. Suba a API (terminal 1)

**Windows (PowerShell ou CMD)**

```powershell
cd api
.\mvnw.cmd spring-boot:run
```

**Linux / macOS**

```bash
cd api
chmod +x mvnw
./mvnw spring-boot:run
```

A primeira execução baixa as dependências e pode levar alguns minutos. A API está pronta quando aparecer no terminal:

```text
Dados iniciais prontos: 12 vagas, admin@park.com e cliente@park.com com senha 123456
```

| Recurso | Endereço |
| --- | --- |
| API | http://localhost:8080 |
| Swagger (documentação interativa) | http://localhost:8080/docs-park.html |
| Console do banco H2 | http://localhost:8080/h2-console (JDBC URL `jdbc:h2:mem:demo_park`, usuário `root`, senha `root`) |

### 4. Rode o aplicativo (terminal 2)

```bash
cd park_app
flutter pub get
flutter run -d chrome
```

O navegador abre automaticamente com a tela de login.

### 5. Entre com os usuários de teste

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Administrador | `admin@park.com` | `123456` |
| Motorista sem histórico | `cliente@park.com` | `123456` |
| Motoristas com histórico | `motorista1@park.com` a `motorista6@park.com` | `123456` |

A API também gera uma semana de movimentação de demonstração (entradas, saídas, pagamentos e quatro veículos no pátio), para o dashboard já começar com dados. Para iniciar sem esses dados, use `app.seed.demo=false` em `api/src/main/resources/application.properties`.

Também é possível criar novos motoristas pela opção **Criar conta** (a senha deve ter exatamente 6 caracteres).

### 6. Roteiro rápido de teste

1. Entre como **motorista**, toque em **Solicitar vaga**, preencha o formulário e veja o ticket com QR Code na aba **Minha vaga**.
2. Saia e entre como **administrador**: o dashboard mostra a vaga ocupada e a entrada do dia.
3. Na aba **Ler QR**, aponte a câmera para o QR Code do motorista ou digite o número do recibo exibido no ticket.
4. Clique em **Registrar saída e cobrar**, escolha a forma de pagamento e confirme para liberar a vaga.
5. Em **Configurações**, informe a chave Pix do estacionamento para que a saída mostre o QR Code Pix com o valor da cobrança.
6. Em **Histórico**, filtre por período e clique em **Exportar planilha** para baixar o CSV.

### Rodando em outros dispositivos

| Onde o app roda | Comando |
| --- | --- |
| Navegador (Chrome) | `flutter run -d chrome` |
| Emulador Android | `flutter run` (o app usa `http://10.0.2.2:8080` automaticamente) |
| Celular físico na mesma rede Wi-Fi | `flutter run --dart-define=API_BASE_URL=http://IP_DO_COMPUTADOR:8080` |
| API hospedada em outro servidor | `flutter run -d chrome --dart-define=API_BASE_URL=https://endereco-da-api` |

Para descobrir o IP do computador: `ipconfig` no Windows ou `ip addr` / `ifconfig` no Linux e macOS.

### Rodando a API com Docker (opcional)

```bash
cd api
docker build -t parkapi .
docker run -p 8080:8080 parkapi
```

### Testes

```bash
cd park_app
flutter test

cd ../api
./mvnw test
```

### Problemas comuns

| Sintoma | Solução |
| --- | --- |
| "Falha de conexão com a API" no app | Confirme que a API está rodando no terminal 1 e acessível em http://localhost:8080/docs-park.html |
| `Port 8080 was already in use` | Feche o programa que usa a porta 8080 ou rode a API com `--server.port=8081` e o app com `--dart-define=API_BASE_URL=http://127.0.0.1:8081` |
| `JAVA_HOME is not set` | Configure a variável `JAVA_HOME` apontando para a pasta do JDK 17 |
| `permission denied: ./mvnw` (Linux/macOS) | Rode `chmod +x mvnw` |
| Câmera não abre na aba Ler QR | O navegador só libera a câmera em `localhost` ou `https`; use a digitação do recibo como alternativa |
| Dados sumiram | O banco H2 é em memória e é recriado a cada reinício da API |

---

## ☁️ Deploy

### Aplicativo web na Vercel

O arquivo `vercel.json` já configura o build: a Vercel instala o Flutter, compila o app web e publica a pasta `park_app/build/web`.

1. Na Vercel, clique em **Add New → Project** e importe este repositório do GitHub.
2. Mantenha **Root Directory** na raiz do repositório (as configurações de build são lidas do `vercel.json`).
3. Em **Environment Variables**, crie `API_BASE_URL` com o endereço público da API (por exemplo `https://parkapi.onrender.com`).
4. Clique em **Deploy**. A cada novo push na branch principal a Vercel publica uma nova versão.

### API

A Vercel hospeda apenas o aplicativo web. A API é publicada no [Render](https://render.com) a partir do arquivo `render.yaml`:

1. No Render, clique em **New → Blueprint** e selecione este repositório.
2. Confirme a criação do serviço `parkapi-api` (plano gratuito, build pelo `api/Dockerfile`).
3. Copie o endereço gerado (por exemplo `https://parkapi-api.onrender.com`) e use-o na variável `API_BASE_URL` da Vercel.

No plano gratuito o serviço hiberna após um período sem acesso; a primeira requisição depois disso leva cerca de um minuto. Como o banco é em memória, os dados voltam ao estado inicial a cada reinício.

A API também pode ser publicada em qualquer outro serviço que rode contêineres Docker usando o `api/Dockerfile`. A porta é lida da variável `PORT` quando o serviço a define.

---

## 🔗 Principais Endpoints

| Operação | Endpoint |
| --- | --- |
| Login | `POST /api/v1/auth` |
| Cadastro de usuários | `POST /api/v1/usuarios` |
| Clientes | `/api/v1/clientes` |
| Consulta de vaga | `GET /api/v1/vagas/{codigo}` |
| Check-in | `POST /api/v1/estacionamentos/check-in` |
| Consulta por recibo | `GET /api/v1/estacionamentos/check-in/{recibo}` |
| Check-out | `PUT /api/v1/estacionamentos/check-out/{recibo}` |
| Histórico | `GET /api/v1/estacionamentos` |
| Relatório PDF | `GET /api/v1/estacionamentos/relatorio` |
| Solicitar vaga (cliente) | `POST /api/v1/estacionamentos/solicitar` |
| Ticket ativo do cliente | `GET /api/v1/estacionamentos/ativo` |
| Veículos no pátio | `GET /api/v1/estacionamentos/ativos` |
| Histórico geral | `GET /api/v1/estacionamentos/todos` |
| Lista de vagas | `GET /api/v1/vagas` |
| Disponibilidade | `GET /api/v1/vagas/disponibilidade` |
| Dashboard | `GET /api/v1/dashboard` |
| Mapa de vagas (motorista) | `GET /api/v1/vagas/mapa` |
| Prévia do valor de saída | `GET /api/v1/estacionamentos/check-in/{recibo}/previa` |
| Check-out com forma de pagamento | `PUT /api/v1/estacionamentos/check-out/{recibo}?formaPagamento=PIX` |
| Histórico com filtros | `GET /api/v1/estacionamentos/todos?placa=&inicio=&fim=` |
| Exportar CSV | `GET /api/v1/estacionamentos/exportar` |
| Tabela de preços | `GET` / `PUT /api/v1/tarifas` |
| Usuário logado | `GET /api/v1/usuarios/me` |
| Alterar perfil | `PATCH /api/v1/usuarios/{id}/perfil` |

---

## 👨‍💻 Autores

Projeto desenvolvido com 💜 por estudantes do IFSP.

<table align="center">
  <tr>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/u/155771396?v=4" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Geisiele Oliveira</b><br>
      <a href="https://github.com/GeisieleOliveira" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-GeisieleOliveira-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/juayumi" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Juliana Ayumi</b><br>
      <a href="https://github.com/juayumi" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-juayumi-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/Thiagolvc" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Thiago Oliveira</b><br>
      <a href="https://github.com/Thiagolvc" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-Thiagolvc-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
    <td align="center" width="200px">
      <img src="https://avatars.githubusercontent.com/Viniciusmagal" width="100" height="100" style="border-radius:50%; object-fit:cover;"/><br>
      <b>Vinicius Magalhães</b><br>
      <a href="https://github.com/Viniciusmagal" target="_blank">
        <img src="https://img.shields.io/badge/GitHub-Viniciusmagal-black?style=for-the-badge&logo=github"/>
      </a>
    </td>
  </tr>
</table>

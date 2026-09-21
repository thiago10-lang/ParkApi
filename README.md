<div align="center">

# 🅿️ ParkingAPI

**Sistema de gerenciamento de estacionamento com API REST e aplicativo mobile.**

![Java](https://img.shields.io/badge/Backend-Java%2017-orange?style=for-the-badge&logo=openjdk)
![Spring Boot](https://img.shields.io/badge/Framework-Spring%20Boot-6DB33F?style=for-the-badge&logo=springboot)
![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?style=for-the-badge&logo=flutter)

[Sobre](#-sobre) • [Funcionalidades](#-funcionalidades) • [Tecnologias](#-tecnologias-utilizadas) • [Instalação](#-instalação-e-execução) • [Autores](#-autores)

</div>

---

## 🖼 Sobre

O **ParkingAPI** é um sistema de gerenciamento de estacionamento desenvolvido como parte do Projeto Semestral do curso de Análise e Desenvolvimento de Sistemas — IFSP.

A aplicação possui uma API REST criada em Spring Boot e um aplicativo mobile desenvolvido em Flutter. O sistema permite controlar usuários, clientes, vagas, entrada e saída de veículos, histórico de estacionamentos e relatórios em PDF.

---

## 🚀 Funcionalidades

### 👤 Cliente

- Login com autenticação JWT
- Consulta dos próprios registros de estacionamento
- Consulta de veículo pelo número do recibo
- Visualização do histórico de entradas e saídas
- Geração de relatório em PDF

### 🔐 Administrativo

- Cadastro de usuários
- Cadastro de clientes
- Cadastro e consulta de vagas
- Check-in de veículos
- Check-out de veículos
- Consulta de histórico por CPF
- Controle de vagas livres e ocupadas

### 📱 Aplicativo Mobile

- Tela de login
- Dashboard inicial
- Consulta de vagas
- Check-in e check-out
- Histórico de estacionamentos
- Relatório
- Persistência segura do token JWT

---

## 🛠 Tecnologias Utilizadas

| Tecnologia | Descrição |
| --- | --- |
| ![Java](https://img.shields.io/badge/JAVA-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white) | **Java 17 — Backend**<br><br>O backend foi desenvolvido em Java utilizando uma arquitetura em camadas, com controllers, services, repositories e entidades.<br><br>**Principais responsabilidades:**<br>• Regras de negócio do estacionamento<br>• Cadastro de usuários, clientes e vagas<br>• Check-in e check-out de veículos<br>• Histórico de estacionamentos |
| ![Spring Boot](https://img.shields.io/badge/SPRING%20BOOT-6DB33F?style=for-the-badge&logo=springboot&logoColor=white) | **Spring Boot — API REST**<br><br>O Spring Boot foi utilizado para construir a API REST do sistema.<br><br>**Recursos utilizados:**<br>• Controllers para os endpoints da API<br>• Services para concentrar as regras de negócio<br>• Validações de dados recebidos<br>• Tratamento de exceções<br>• Respostas em JSON |
| ![Spring Security](https://img.shields.io/badge/SPRING%20SECURITY-6DB33F?style=for-the-badge&logo=springsecurity&logoColor=white) | **Spring Security + JWT — Autenticação**<br><br>O sistema utiliza autenticação baseada em token JWT.<br><br>**Funcionalidades:**<br>• Login com e-mail e senha<br>• Geração de token JWT<br>• Proteção de rotas da API<br>• Controle de acesso para os perfis `ADMIN` e `CLIENTE`<br>• Sessão stateless |
| ![MySQL](https://img.shields.io/badge/MYSQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white) | **MySQL — Banco de Dados**<br><br>O MySQL é utilizado para armazenar os dados do sistema.<br><br>**Dados armazenados:**<br>• Usuários<br>• Clientes<br>• Vagas<br>• Veículos estacionados<br>• Registros de check-in e check-out |
| ![Hibernate](https://img.shields.io/badge/HIBERNATE-59666C?style=for-the-badge&logo=hibernate&logoColor=white) | **Spring Data JPA + Hibernate — Persistência**<br><br>Responsáveis pela comunicação entre a aplicação Java e o banco MySQL.<br><br>**Recursos utilizados:**<br>• Mapeamento de entidades<br>• Repositories<br>• Consultas paginadas<br>• Persistência de dados com JPA |
| ![Swagger](https://img.shields.io/badge/SWAGGER-85EA2D?style=for-the-badge&logo=swagger&logoColor=black) | **Swagger / Springdoc — Documentação da API**<br><br>O Swagger documenta e permite testar os endpoints da API diretamente pelo navegador.<br><br>**Acesso:**<br>`http://localhost:8080/docs-park.html` |
| ![Flutter](https://img.shields.io/badge/FLUTTER-02569B?style=for-the-badge&logo=flutter&logoColor=white) | **Flutter + Dart — Aplicativo Mobile**<br><br>O aplicativo mobile foi desenvolvido em Flutter e integrado à API Spring Boot.<br><br>**Funcionalidades:**<br>• Tela de login<br>• Dashboard<br>• Consulta de vagas<br>• Check-in e check-out<br>• Histórico<br>• Relatório |
| ![JasperReports](https://img.shields.io/badge/JASPERREPORTS-DF0000?style=for-the-badge) | **JasperReports — Relatórios em PDF**<br><br>Utilizado para gerar relatórios em PDF com os registros de estacionamento do cliente. |

---

## 📂 Estrutura do Projeto

```text
ParkingAPI/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/mballem/demoparkapi/
│   │   │       ├── config/
│   │   │       ├── entity/
│   │   │       ├── jwt/
│   │   │       ├── repository/
│   │   │       ├── service/
│   │   │       └── web/
│   │   └── resources/
│   │       ├── reports/
│   │       └── application.properties
├── flutter/
│   ├── lib/
│   ├── android/
│   └── pubspec.yaml
├── pom.xml
└── README.md
```

---

## 🔧 Instalação e Execução

### Pré-requisitos

- Java 17
- MySQL
- Flutter SDK
- Android Studio ou emulador Android

### 1. Banco de Dados

Crie o banco:

```sql
CREATE DATABASE demo_park;
```

Confira as credenciais em:

```text
src/main/resources/application.properties
```

### 2. Backend

Na raiz do projeto:

```powershell
.\mvnw.cmd spring-boot:run
```

A API estará disponível em:

```text
http://localhost:8080
```

Swagger:

```text
http://localhost:8080/docs-park.html
```

### 3. Aplicativo Flutter

Em outro terminal:

```powershell
cd flutter
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

> `10.0.2.2` funciona no emulador Android. Em celular físico, use o IP do computador, por exemplo: `http://192.168.0.10:8080`.

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

---

## 👨‍💻 Autores

Projeto desenvolvido por estudantes do IFSP.

- Geisiele Oliveira
- Thiago Camargo
- Vinicius Arantes
- Vinicius Magalhães

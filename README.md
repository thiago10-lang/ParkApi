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
| Java 17 | Linguagem utilizada no backend. |
| Spring Boot | API REST, regras de negócio, controllers, services e validações. |
| Spring Security + JWT | Autenticação e controle de acesso para `ADMIN` e `CLIENTE`. |
| MySQL | Banco de dados relacional da aplicação. |
| Spring Data JPA / Hibernate | Persistência e consultas ao banco de dados. |
| Swagger / Springdoc | Documentação interativa dos endpoints. |
| Flutter + Dart | Aplicativo mobile integrado à API. |
| JasperReports | Geração de relatórios em PDF. |

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

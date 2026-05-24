# NDZALAMA IA

AI-powered financial fraud detection and financial education platform focused on Mozambique and African mobile money ecosystems.

---

# Vision

Ndzalama IA aims to help people:

* detect financial scams;
* identify suspicious mobile money messages;
* improve financial literacy;
* protect personal financial information;
* build safer digital financial habits.

The platform combines:

* fraud intelligence;
* gamification;
* financial education;
* AI-powered analysis.

---

# Tech Stack

## Backend

* Java 21
* Spring Boot 3
* Spring Security
* JWT Authentication
* PostgreSQL
* Hibernate / JPA
* Maven

---

# Current Features

# Authentication System

Implemented using JWT and Spring Security.

## Features

* User registration
* User login
* Access tokens
* Refresh tokens
* Password encryption with BCrypt
* Protected API routes

---

# Fraud Detection Engine

AI-inspired fraud analysis engine for suspicious financial messages.

## Supported Detection

* fake bonuses;
* suspicious promotions;
* mobile money fraud;
* PIN/OTP requests;
* phishing links;
* urgency manipulation;
* fake support agents;
* social engineering tactics;
* suspicious money transfer requests.

---

## Fraud Classification

Messages are classified as:

```txt
LEGÍTIMO
SUSPEITO
FRAUDE
```

---

## Risk Scoring

Each analysis generates:

* risk score;
* detected signals;
* security advice.

---

# Fraud History

Every authenticated user has:

* fraud analysis history;
* persistent fraud reports;
* fraud timeline stored in PostgreSQL.

---

# Financial Education Engine

Educational system focused on digital financial safety.

## Features

* daily financial tips;
* anti-fraud education;
* budgeting advice;
* savings recommendations;
* mobile money security awareness.

---

# Gamification System

Users earn points and achievements while learning and protecting themselves.

## Features

* points;
* levels;
* achievements;
* badges;
* progress tracking.

---

## Current Achievements

| Code              | Achievement           |
| ----------------- | --------------------- |
| FRAUD_BEGINNER    | Primeiro Alerta       |
| FRAUD_HUNTER      | Caçador de Fraudes    |
| SECURITY_GUARDIAN | Guardião Financeiro   |
| LEVEL_3           | Utilizador Experiente |

---

# API Endpoints

# Authentication

## Register

```http
POST /api/v1/auth/register
```

## Login

```http
POST /api/v1/auth/login
```

---

# Fraud Detection

## Analyze Text

```http
POST /api/v1/fraud/analyze-text
```

## Fraud History

```http
GET /api/v1/fraud/history
```

---

# Education

## Daily Tip

```http
GET /api/v1/education/daily-tip
```

## All Tips

```http
GET /api/v1/education/tips
```

---

# Gamification

## User Profile

```http
GET /api/v1/gamification/profile
```

## Achievements

```http
GET /api/v1/gamification/achievements
```

---

# Example Fraud Detection Response

```json
{
  "classification": "FRAUDE",
  "riskScore": 100,
  "detectedSignals": [
    "Bónus, prémio ou promoção suspeita detectada.",
    "Referência a serviço financeiro ou dinheiro móvel detectada.",
    "Pedido de PIN, OTP ou código de verificação detectado."
  ],
  "advice": "Não envie dinheiro, não clique em links e nunca partilhe PIN, OTP ou palavras-passe."
}
```

---

# Security

The platform uses:

* JWT authentication;
* stateless sessions;
* BCrypt password hashing;
* protected endpoints;
* authentication filters.

---

# Project Structure

```txt
backend/
├── config/
├── controller/
├── dto/
├── model/
├── repository/
├── security/
├── service/
```

---

# Roadmap

## Next Features

* OCR fraud detection;
* image scam analysis;
* fake receipt detection;
* URL reputation system;
* quizzes;
* streak system;
* Flutter mobile app;
* AI fraud models;
* admin dashboard.

---

# Running the Project

# Requirements

* Java 21
* PostgreSQL
* Maven

---

# Database

Create a PostgreSQL database:

```sql
CREATE DATABASE ndzalama;
```

---

# Configuration

Create:

```txt
application-local.properties
```

Example:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/ndzalama
spring.datasource.username=postgres
spring.datasource.password=YOUR_PASSWORD

jwt.secret=YOUR_SECRET_KEY
jwt.access-expiration=1800000
jwt.refresh-expiration=604800000
```

---

# Run Backend

```bash
mvn spring-boot:run
```

---

# Swagger

```txt
http://localhost:8081/swagger-ui/index.html
```

---

# Authors

Aristides Guilherme & Yasser Cardoso

---

# License

MIT License

# WorkHub — Aplicativo de Produtividade para Equipes

WorkHub é um aplicativo mobile Flutter voltado para maximizar a produtividade no ambiente de trabalho, ajudando equipes e profissionais a organizarem seu dia com eficiência.

---

## 📱 Funcionalidades

### 1. Painel (Dashboard)
- Saudação personalizada baseada no horário
- Cards de estatísticas: tarefas concluídas, em andamento, pomodoros e notas
- Visualização de tarefas prioritárias (Alta / Urgente)
- Progresso visual das metas diárias

### 2. Tarefas
- Lista de tarefas com abas: **A fazer**, **Em andamento**, **Concluídas**
- Criação de tarefas com título, descrição e prioridade (Baixa / Média / Alta / Urgente)
- Status visual com indicadores de cor
- Deslize para excluir (swipe to delete)
- Filtro por busca textual
- Indicadores de prazo (ex: "Em 3h", "Atrasada")
- Detalhes da tarefa em bottom sheet

### 3. Timer de Foco (Pomodoro)
- Modos: Foco (25min), Pausa Curta (5min), Pausa Longa (15min)
- Anel de progresso animado com efeito glow pulsante
- Controles: Play/Pause, Reset, Skip
- Contador de sessões do dia
- Indicador visual de ciclo (4 pomodoros = 1 ciclo)
- Seleção da tarefa em foco

### 4. Notas
- Editor de notas com cores temáticas (Azul, Roxo, Verde, Laranja, Vermelho)
- Suporte a tags personalizadas
- Fixar/desafixar notas
- Busca por texto
- Interface de edição full-screen imersiva

### 5. Metas do Dia
- Acompanhamento de 4 métricas: Tarefas, Pomodoros, Reuniões, E-mails
- Anel de progresso geral com percentual
- Incremento/decremento manual de cada meta
- Barra de progresso individual por meta
- Resumo de tempo de foco e produtividade

---

## 🗂 Estrutura de Arquivos

```
lib/
├── main.dart                      # Ponto de entrada
├── theme/
│   └── app_theme.dart             # Cores, tipografia, tema escuro
├── models/
│   └── models.dart                # Task, Note, DailyGoal, PomodoroSession
├── state/
│   └── app_state.dart             # Estado global (ChangeNotifier)
├── widgets/
│   └── common_widgets.dart        # GlowContainer, ProgressRing, StatCard, etc.
└── screens/
    ├── home_screen.dart            # Shell com bottom navigation
    ├── dashboard_screen.dart       # Tela inicial / painel
    ├── tasks_screen.dart           # Gerenciamento de tarefas
    ├── pomodoro_screen.dart        # Timer de foco
    ├── notes_screen.dart           # Notas e anotações
    └── goals_screen.dart           # Metas e acompanhamento
```

---

## 🎨 Design

**Paleta:** Fundo navy profundo `#0A0E1A` com destaque em cyan elétrico `#00E5FF` e roxo `#7C3AED`

**Estilo:** Dark UI industrial-refinado, com:
- Cards com bordas sutis e sombras de glow
- Animações de pulso no timer Pomodoro
- Barras e anéis de progresso
- Gradientes contextuais no header
- Bottom navigation minimalista com badges

---

## 🚀 Como Rodar

### Pré-requisitos
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code com extensão Flutter
- Dispositivo Android / iOS ou emulador

### Instalação

```bash
# Clone ou copie os arquivos para uma pasta
cd workhub_app

# Instale dependências
flutter pub get

# Execute no dispositivo/emulador
flutter run
```

### Build de produção

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🔧 Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| Framework | Flutter (Dart) |
| Estado | ChangeNotifier + AnimatedBuilder |
| UI | Material 3 customizado |
| Animações | AnimationController, CustomPainter |
| Timer | dart:async Timer.periodic |
| Persistência | In-memory (pronto para SharedPreferences/SQLite) |

---

## 📈 Extensões Sugeridas

Para evolução do app, considere adicionar:
- **Persistência local** com `shared_preferences` ou `sqflite`
- **Notificações push** com `flutter_local_notifications`
- **Sincronização em nuvem** com Firebase Firestore
- **Calendário** com `table_calendar`
- **Exportar relatórios** em PDF
- **Autenticação** com Firebase Auth

---

*Desenvolvido com Flutter — Design dark mode de alta produtividade para equipes modernas.*

# 🚀 Priora

> **An AI-powered productivity companion that transforms chaotic thoughts into intelligent action plans.**

Priora is a Flutter application that leverages **Google Gemini**, **Firebase**, and **AI-powered planning** to help users capture thoughts, prioritize tasks, optimize schedules, and stay ahead of deadlines.

Built as a hackathon project, Priora acts as an **AI Chief of Staff** rather than a traditional to-do list.

---

# ✨ Features

## 🧠 AI Brain Dump

- Write or speak everything on your mind
- Voice-to-text support
- AI extracts actionable tasks
- Generates summaries automatically

---

## 📋 Smart Task Planning

Gemini automatically assigns:

- Priority
- Category
- Estimated duration
- Deadline
- Urgency
- Importance
- Energy level
- Daily plan

---

## 📅 Intelligent Planner

- Firestore-backed task list
- Mark tasks complete
- Live synchronization
- Automatic dashboard updates

---

## 🚨 Rescue Mode

Priora detects:

- High-risk tasks
- Deadline overload
- Critical priorities

Then generates an emergency execution strategy.

---

## 🤖 AI Schedule Assistant

Instead of being a normal chatbot, Priora can:

- Replan your day
- Reassign task durations
- Suggest better schedules
- Protect important deadlines

Example:

> "I only have 2 hours tonight."

Priora automatically proposes a new schedule and lets you apply it with one click.

---

## 📊 Dashboard

See:

- Productivity summary
- Completion progress
- High-priority tasks
- Recommended next task

---

# 🏗 Tech Stack

| Layer | Technology |
|--------|------------|
| Frontend | Flutter |
| Language | Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| AI | Google Gemini |
| Voice Input | speech_to_text |
| Environment Variables | flutter_dotenv |

---

# 🏛 Architecture

```
                +----------------------+
                |      Flutter App     |
                +----------+-----------+
                           |
          +----------------+----------------+
          |                                 |
     Firebase                      Google Gemini
          |                                 |
   +------+-------+                AI Planning Engine
   |              |
Authentication  Firestore
                    |
    +---------------+-----------------------------+
    |               |            |               |
 Brain Dumps      Tasks     Daily Plans      AI Chat
```

---

# 📂 Firestore Structure

```
users/{uid}
│
├── brain_dumps
│
├── tasks
│
├── daily_plans
│
└── chat_conversations
        └── main
              └── messages
```

---

# 📱 Screens

- Login
- Home Dashboard
- Brain Dump
- AI Analysis
- Planner
- Rescue Mode
- AI Chat
- Profile

---

# 🚀 Demo Flow

1. Sign in with Google
2. Create a Brain Dump
3. Analyze with AI
4. View generated tasks
5. Open Planner
6. Mark tasks complete
7. Use Rescue Mode
8. Ask AI Chat to reschedule
9. Apply new schedule
10. Planner updates automatically

---

# ⚙️ Installation

Clone the repository

```bash
git clone https://github.com/purva-06/priora.git
cd priora
```

Install dependencies

```bash
flutter pub get
```

Configure Firebase

```bash
flutterfire configure
```

Create a `.env` file

```env
GEMINI_API_KEY=YOUR_API_KEY
```

Run

```bash
flutter run
```

---


# 🎯 Hackathon Highlights

✅ Flutter

✅ Firebase Authentication

✅ Cloud Firestore

✅ Google Gemini

✅ AI Task Planning

✅ AI Schedule Replanning

✅ Voice Input

✅ Persistent AI Chat

---

# 🔒 Security

- Google Authentication
- Firestore Security Rules
- Environment variables via `.env`
- No API keys committed to Git

---

# 🚀 Future Enhancements

- Google Calendar integration
- Gmail task extraction
- Push notifications
- Focus analytics
- Habit tracking
- Team collaboration
- Cloud Functions for secure AI requests
- Multi-day schedule optimization

---

# 👩‍💻 Author

**Purva Tripathi**

GitHub: https://github.com/purva-06

---

# 📄 License

MIT License

# 🎓 MentorConnect

**MentorConnect** is a comprehensive, smart mentoring platform designed to bridge the gap between junior students and experienced mentors (peers, seniors, and professionals). Built with a focus on personalized matching and efficient issue resolution, it ensures every student gets the guidance they need to succeed academically and personally.

## 🚀 Key Features

### 🧠 Smart Demographic Matching
Our proprietary matching engine pairs mentees with the most suitable mentors using a weighted scoring algorithm (0.0 - 1.0) based on:
- **Academic Background (30%)**: PCM, PCB, Commerce, Arts, etc.
- **Mentoring Domains (25%)**: Academics, Career, Mental Health, etc.
- **Language Compatibility (20%)**: Multi-language support (English, Hindi, etc.).
- **Department Similarity (15%)**: Connecting students within the same college branch.
- **Shared Interests (10%)**: Matching based on hobbies and technical interests.

### 📝 Integrated Issue Tracking
A built-in system for mentees to raise challenges and for mentors to provide solutions:
- **Categorized Issues**: Academic, Career, Personal, etc.
- **Visibility Levels**: Public, Private, and Ultra-Private for sensitive matters.
- **Threaded Discussions**: Collaborative problem-solving with nested comments.
- **Resolution Tracking**: Formal closing of issues with mentor attribution.

### 👥 Diverse Mentor Roles
- **Peer Mentors**: 2nd-year undergraduates helping freshers.
- **Senior Mentors**: 3rd/4th-year undergraduates providing advanced guidance.
- **Postgraduate Mentors**: M.Tech / PhD scholars for specialized research advice.
- **Professional Counsellors**: Certified experts for mental health and career crisis management.

### 🔒 Privacy & Security
- **Ultra-Private Mode**: High-sensitivity issues are auto-escalated to professional counsellors.
- **Audit Logging**: Every sensitive action is logged for accountability.
- **Anonymous Posting**: Mentees can ask questions without revealing their identity.

---

## 🛠️ Tech Stack

- **Frontend**: [Next.js 15](https://nextjs.org/) (App Router), [Tailwind CSS](https://tailwindcss.com), [Framer Motion](https://www.framer.com/motion/)
- **Backend & Auth**: [Supabase](https://supabase.com/) (PostgreSQL, Realtime, SSR)
- **UI Components**: [Shadcn/UI](https://ui.shadcn.com/)
- **Icons**: [Lucide React](https://lucide.dev/)

---

## 🛠️ Getting Started

### 1. Prerequisite
Ensure you have [Node.js](https://nodejs.org/) installed and a [Supabase](https://supabase.com/) project set up.

### 2. Clone and Setup
```bash
git clone https://github.com/your-repo/mentorconnect.git
cd mentorconnect
```

### 3. Environment Variables
Create a `.env.local` file in the root directory:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=your_supabase_anon_key
```

### 4. Install Dependencies
```bash
npm install
```

### 5. Run Development Server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

---

## 📈 Matching Engine Usage
Mentees can trigger a fresh match calculation from their profile page. The system will look at their academic background, preferred languages, and interests to suggest the top 5 mentors currently accepting new mentees.


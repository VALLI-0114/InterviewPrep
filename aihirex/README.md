# AIHireX

AI-Powered Interview Automation Platform built with Next.js 14, FastAPI, and Supabase.

## Architecture

```text
+-------------------+       REST API      +-----------------------+
|  Next.js 14       | <=================> |  FastAPI Backend      |
|  (Frontend)       |                     |  (Backend)            |
|  - App Router     |                     |  - Groq API           |
|  - Tailwind CSS   |                     |  - Supabase Storage   |
|  - WebRTC (STT)   |                     |  - PyMuPDF            |
|  - face-api.js    |                     +-----------------------+
+-------------------+                                |
                                                     v
                                          +-----------------------+
                                          |  Supabase (PostgreSQL)|
                                          |  - Row Level Security |
                                          +-----------------------+
```

## Setup Instructions

### Environment Variables

**Frontend (`frontend/.env.local`)**
```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

**Backend (`backend/.env`)**
```env
GROQ_API_KEY=your_groq_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_supabase_service_role_key
OPENAI_API_KEY=your_openai_api_key
```

### Running Locally

1. **Start the Backend**
   ```bash
   cd backend
   poetry install
   poetry run uvicorn main:app --reload
   ```

2. **Start the Frontend**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

3. Open `http://localhost:3000`

### Database
Run the provided `schema.sql` in your Supabase SQL Editor.

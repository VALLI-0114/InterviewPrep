-- Migration: Initial Schema for AIHireX
-- Description: Create tables for candidates, interviews, questions, answers, and violations with RLS policies.

-- Create extension for UUID if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: candidates
CREATE TABLE IF NOT EXISTS candidates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    resume_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: interviews
CREATE TABLE IF NOT EXISTS interviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID REFERENCES candidates(id) ON DELETE CASCADE,
    status TEXT CHECK (status IN ('pending', 'active', 'completed', 'failed')) DEFAULT 'pending',
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    overall_score FLOAT,
    technical_score FLOAT,
    communication_score FLOAT,
    ai_feedback TEXT
);

-- Table: questions
CREATE TABLE IF NOT EXISTS questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    interview_id UUID REFERENCES interviews(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    order_index INT NOT NULL,
    time_limit_seconds INT DEFAULT 60
);

-- Table: answers
CREATE TABLE IF NOT EXISTS answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    transcript TEXT,
    audio_url TEXT,
    score FLOAT,
    ai_evaluation TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: violations
CREATE TABLE IF NOT EXISTS violations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    interview_id UUID REFERENCES interviews(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('tab_switch', 'fullscreen_exit', 'multiple_faces', 'no_face', 'copy_paste', 'eye_tracking')),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    screenshot_url TEXT
);

-- ENABLE ROW LEVEL SECURITY
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE interviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE violations ENABLE ROW LEVEL SECURITY;

-- POLICIES

-- Candidates Policies
-- Candidates can view and update their own data
CREATE POLICY "Candidates can view own data" 
ON candidates FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Candidates can update own data" 
ON candidates FOR UPDATE 
USING (auth.uid() = id);

-- Admins can do everything
CREATE POLICY "Admins can do everything on candidates" 
ON candidates FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Interviews Policies
CREATE POLICY "Candidates can view own interviews" 
ON interviews FOR SELECT 
USING (candidate_id = auth.uid());

CREATE POLICY "Candidates can update own interviews" 
ON interviews FOR UPDATE 
USING (candidate_id = auth.uid());

CREATE POLICY "Candidates can insert own interviews" 
ON interviews FOR INSERT 
WITH CHECK (candidate_id = auth.uid());

CREATE POLICY "Admins can do everything on interviews" 
ON interviews FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Questions Policies
CREATE POLICY "Candidates can view questions for their interviews" 
ON questions FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM interviews 
    WHERE interviews.id = questions.interview_id AND interviews.candidate_id = auth.uid()
  )
);

CREATE POLICY "Admins can do everything on questions" 
ON questions FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Answers Policies
CREATE POLICY "Candidates can insert answers for their questions" 
ON answers FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM questions 
    JOIN interviews ON questions.interview_id = interviews.id 
    WHERE questions.id = answers.question_id AND interviews.candidate_id = auth.uid()
  )
);

CREATE POLICY "Candidates can view own answers" 
ON answers FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM questions 
    JOIN interviews ON questions.interview_id = interviews.id 
    WHERE questions.id = answers.question_id AND interviews.candidate_id = auth.uid()
  )
);

CREATE POLICY "Admins can do everything on answers" 
ON answers FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Violations Policies
CREATE POLICY "Candidates can insert violations for their interviews" 
ON violations FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM interviews 
    WHERE interviews.id = violations.interview_id AND interviews.candidate_id = auth.uid()
  )
);

CREATE POLICY "Candidates can view own violations" 
ON violations FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM interviews 
    WHERE interviews.id = violations.interview_id AND interviews.candidate_id = auth.uid()
  )
);

CREATE POLICY "Admins can do everything on violations" 
ON violations FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE auth.uid() = id AND raw_user_meta_data->>'role' = 'admin'
  )
);

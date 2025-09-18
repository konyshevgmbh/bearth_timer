-- Supabase database schema for bearth_timer application
-- This script creates all necessary tables and policies for exercise and user data sync

-- Enable Row Level Security
-- Note: Run these commands in the Supabase SQL editor

-- Create breathing_exercises table
CREATE TABLE IF NOT EXISTS public.breathing_exercises (
    id TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ DEFAULT NULL,
    min_cycles INTEGER NOT NULL,
    max_cycles INTEGER NOT NULL,
    cycle_duration_step INTEGER NOT NULL,
    cycles INTEGER NOT NULL,
    cycle_duration INTEGER NOT NULL,
    PRIMARY KEY (user_id, id)
);

-- Create breath_phases table
CREATE TABLE IF NOT EXISTS public.breath_phases (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    exercise_id TEXT NOT NULL,
    exercise_user_id UUID NOT NULL,
    name TEXT NOT NULL,
    duration INTEGER NOT NULL,
    min_duration INTEGER NOT NULL,
    max_duration INTEGER NOT NULL,
    color_value BIGINT NOT NULL,
    phase_order INTEGER NOT NULL,
    claps INTEGER DEFAULT 1 NOT NULL,
    deleted_at TIMESTAMPTZ DEFAULT NULL,
    FOREIGN KEY (exercise_user_id, exercise_id) REFERENCES public.breathing_exercises(user_id, id) ON DELETE CASCADE
);

-- Create training_results table
CREATE TABLE IF NOT EXISTS public.training_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    exercise_id TEXT,
    date TIMESTAMPTZ NOT NULL,
    duration INTEGER NOT NULL,
    cycles INTEGER NOT NULL,
    score REAL,
    deleted_at TIMESTAMPTZ DEFAULT NULL
);

-- Create user_settings table
CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    total_cycles INTEGER DEFAULT 4,
    cycle_duration INTEGER DEFAULT 60,
    sound_enabled BOOLEAN DEFAULT true,
    volume REAL DEFAULT 1.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);


-- Enable Row Level Security on all tables
ALTER TABLE public.breathing_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breath_phases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.training_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts (now that tables exist)
DROP POLICY IF EXISTS "Users can view their own exercises" ON public.breathing_exercises;
DROP POLICY IF EXISTS "Users can insert their own exercises" ON public.breathing_exercises;
DROP POLICY IF EXISTS "Users can update their own exercises" ON public.breathing_exercises;
DROP POLICY IF EXISTS "Users can delete their own exercises" ON public.breathing_exercises;

DROP POLICY IF EXISTS "Users can view phases of their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can insert phases for their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can update phases of their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can delete phases of their exercises" ON public.breath_phases;

DROP POLICY IF EXISTS "Users can view their own training results" ON public.training_results;
DROP POLICY IF EXISTS "Users can insert their own training results" ON public.training_results;
DROP POLICY IF EXISTS "Users can update their own training results" ON public.training_results;
DROP POLICY IF EXISTS "Users can delete their own training results" ON public.training_results;

DROP POLICY IF EXISTS "Users can view their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can insert their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can update their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can delete their own settings" ON public.user_settings;

-- Create RLS policies for breathing_exercises
CREATE POLICY "breathing_exercises_select" ON public.breathing_exercises
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "breathing_exercises_insert" ON public.breathing_exercises
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "breathing_exercises_update" ON public.breathing_exercises
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "breathing_exercises_delete" ON public.breathing_exercises
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for breath_phases
CREATE POLICY "breath_phases_select" ON public.breath_phases
    FOR SELECT USING (auth.uid() = exercise_user_id);

CREATE POLICY "breath_phases_insert" ON public.breath_phases
    FOR INSERT WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "breath_phases_update" ON public.breath_phases
    FOR UPDATE USING (auth.uid() = exercise_user_id) WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "breath_phases_delete" ON public.breath_phases
    FOR DELETE USING (auth.uid() = exercise_user_id);

-- Create RLS policies for training_results
CREATE POLICY "training_results_select" ON public.training_results
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "training_results_insert" ON public.training_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "training_results_update" ON public.training_results
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "training_results_delete" ON public.training_results
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for user_settings
CREATE POLICY "user_settings_select" ON public.user_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "user_settings_insert" ON public.user_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_settings_update" ON public.user_settings
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_settings_delete" ON public.user_settings
    FOR DELETE USING (auth.uid() = user_id);


-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_breathing_exercises_user_id ON public.breathing_exercises(user_id);
CREATE INDEX IF NOT EXISTS idx_breathing_exercises_created_at ON public.breathing_exercises(created_at);
CREATE INDEX IF NOT EXISTS idx_breathing_exercises_deleted_at ON public.breathing_exercises(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_breath_phases_exercise ON public.breath_phases(exercise_user_id, exercise_id);
CREATE INDEX IF NOT EXISTS idx_breath_phases_order ON public.breath_phases(exercise_user_id, exercise_id, phase_order);
CREATE INDEX IF NOT EXISTS idx_breath_phases_deleted_at ON public.breath_phases(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_training_results_user_id ON public.training_results(user_id);
CREATE INDEX IF NOT EXISTS idx_training_results_date ON public.training_results(user_id, date);
CREATE INDEX IF NOT EXISTS idx_training_results_exercise_id ON public.training_results(exercise_id);
CREATE INDEX IF NOT EXISTS idx_training_results_deleted_at ON public.training_results(deleted_at) WHERE deleted_at IS NOT NULL;

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop existing triggers to avoid conflicts
DROP TRIGGER IF EXISTS update_breathing_exercises_updated_at ON public.breathing_exercises;
DROP TRIGGER IF EXISTS update_user_settings_updated_at ON public.user_settings;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create triggers for updated_at columns
CREATE TRIGGER update_breathing_exercises_updated_at BEFORE UPDATE
    ON public.breathing_exercises FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE
    ON public.user_settings FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Create function to handle user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Create function to clean up deleted records older than 30 days
CREATE OR REPLACE FUNCTION public.cleanup_deleted_records()
RETURNS VOID AS $$
BEGIN
    -- Clean up training results deleted more than 30 days ago
    DELETE FROM public.training_results 
    WHERE deleted_at IS NOT NULL 
    AND deleted_at < NOW() - INTERVAL '30 days';
    
    -- Clean up breath phases deleted more than 30 days ago
    DELETE FROM public.breath_phases 
    WHERE deleted_at IS NOT NULL 
    AND deleted_at < NOW() - INTERVAL '30 days';
    
    -- Clean up breathing exercises deleted more than 30 days ago
    DELETE FROM public.breathing_exercises 
    WHERE deleted_at IS NOT NULL 
    AND deleted_at < NOW() - INTERVAL '30 days';
    
    -- Log cleanup activity
    RAISE NOTICE 'Cleanup completed: deleted records older than 30 days removed';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule the cleanup function to run daily (requires pg_cron extension)
-- Note: This requires the pg_cron extension to be enabled in your Supabase project
-- Enable it in: Dashboard -> Settings -> Extensions -> pg_cron
-- SELECT cron.schedule('cleanup-deleted-records', '0 2 * * *', 'SELECT public.cleanup_deleted_records();');
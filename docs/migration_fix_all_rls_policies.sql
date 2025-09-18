-- Migration: Fix all RLS policies for soft delete functionality
-- Run this in your Supabase SQL editor to fix all RLS policy violations

-- ===== BREATHING EXERCISES POLICIES =====

-- Drop existing breathing_exercises policies
DROP POLICY IF EXISTS "Users can view their own exercises" ON public.breathing_exercises;
DROP POLICY IF EXISTS "Users can insert their own exercises" ON public.breathing_exercises;
DROP POLICY IF EXISTS "Users can update their own exercises" ON public.breathing_exercises;
DROP POLICY IF EXISTS "Users can delete their own exercises" ON public.breathing_exercises;

-- Create RLS policies for breathing_exercises
CREATE POLICY "Users can view their own exercises" ON public.breathing_exercises
    FOR SELECT USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Users can insert their own exercises" ON public.breathing_exercises
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own exercises" ON public.breathing_exercises
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own exercises" ON public.breathing_exercises
    FOR DELETE USING (auth.uid() = user_id);

-- ===== BREATH PHASES POLICIES =====

-- Drop existing breath_phases policies
DROP POLICY IF EXISTS "Users can view phases of their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can insert phases for their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can update phases of their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can delete phases of their exercises" ON public.breath_phases;

-- Create simplified RLS policies for breath_phases
CREATE POLICY "Users can view phases of their exercises" ON public.breath_phases
    FOR SELECT USING (
        breath_phases.deleted_at IS NULL AND 
        auth.uid() = exercise_user_id
    );

CREATE POLICY "Users can insert phases for their exercises" ON public.breath_phases
    FOR INSERT WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "Users can update phases of their exercises" ON public.breath_phases
    FOR UPDATE USING (auth.uid() = exercise_user_id) WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "Users can delete phases of their exercises" ON public.breath_phases
    FOR DELETE USING (auth.uid() = exercise_user_id);

-- ===== TRAINING RESULTS POLICIES =====

-- Drop existing training_results policies
DROP POLICY IF EXISTS "Users can view their own training results" ON public.training_results;
DROP POLICY IF EXISTS "Users can insert their own training results" ON public.training_results;
DROP POLICY IF EXISTS "Users can update their own training results" ON public.training_results;
DROP POLICY IF EXISTS "Users can delete their own training results" ON public.training_results;

-- Create RLS policies for training_results
CREATE POLICY "Users can view their own training results" ON public.training_results
    FOR SELECT USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Users can insert their own training results" ON public.training_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own training results" ON public.training_results
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own training results" ON public.training_results
    FOR DELETE USING (auth.uid() = user_id);

-- ===== USER SETTINGS POLICIES =====

-- Drop existing user_settings policies
DROP POLICY IF EXISTS "Users can view their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can insert their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can update their own settings" ON public.user_settings;
DROP POLICY IF EXISTS "Users can delete their own settings" ON public.user_settings;

-- Create RLS policies for user_settings
CREATE POLICY "Users can view their own settings" ON public.user_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own settings" ON public.user_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own settings" ON public.user_settings
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own settings" ON public.user_settings
    FOR DELETE USING (auth.uid() = user_id);

-- Show success message
DO $$
BEGIN
    RAISE NOTICE 'RLS policies updated successfully for soft delete functionality';
END
$$;
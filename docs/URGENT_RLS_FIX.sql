-- URGENT: Run this in Supabase SQL Editor immediately
-- This will fix all RLS policy violations

-- First, let's see what policies currently exist
-- SELECT schemaname, tablename, policyname, cmd, permissive, roles, qual, with_check 
-- FROM pg_policies 
-- WHERE schemaname = 'public' AND tablename IN ('breathing_exercises', 'breath_phases', 'training_results');

-- Drop ALL existing policies to start fresh
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

-- Create SIMPLE policies that WILL WORK
-- BREATHING EXERCISES
CREATE POLICY "breathing_exercises_select" ON public.breathing_exercises
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "breathing_exercises_insert" ON public.breathing_exercises
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "breathing_exercises_update" ON public.breathing_exercises
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "breathing_exercises_delete" ON public.breathing_exercises
    FOR DELETE USING (auth.uid() = user_id);

-- BREATH PHASES  
CREATE POLICY "breath_phases_select" ON public.breath_phases
    FOR SELECT USING (auth.uid() = exercise_user_id);

CREATE POLICY "breath_phases_insert" ON public.breath_phases
    FOR INSERT WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "breath_phases_update" ON public.breath_phases
    FOR UPDATE USING (auth.uid() = exercise_user_id) WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "breath_phases_delete" ON public.breath_phases
    FOR DELETE USING (auth.uid() = exercise_user_id);

-- TRAINING RESULTS
CREATE POLICY "training_results_select" ON public.training_results
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "training_results_insert" ON public.training_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "training_results_update" ON public.training_results
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "training_results_delete" ON public.training_results
    FOR DELETE USING (auth.uid() = user_id);

-- Success message
SELECT 'RLS POLICIES FIXED SUCCESSFULLY!' as status;
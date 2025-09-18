-- Migration: Fix breath_phases RLS policies
-- Run this in your Supabase SQL editor to fix the RLS policy violations

-- Drop existing breath_phases policies
DROP POLICY IF EXISTS "Users can insert phases for their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can update phases of their exercises" ON public.breath_phases;
DROP POLICY IF EXISTS "Users can delete phases of their exercises" ON public.breath_phases;

-- Create simplified RLS policies for breath_phases that use exercise_user_id directly
CREATE POLICY "Users can insert phases for their exercises" ON public.breath_phases
    FOR INSERT WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "Users can update phases of their exercises" ON public.breath_phases
    FOR UPDATE USING (auth.uid() = exercise_user_id) WITH CHECK (auth.uid() = exercise_user_id);

CREATE POLICY "Users can delete phases of their exercises" ON public.breath_phases
    FOR DELETE USING (auth.uid() = exercise_user_id);
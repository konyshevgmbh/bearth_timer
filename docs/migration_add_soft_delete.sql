-- Migration: Add soft delete functionality
-- Run this in your Supabase SQL editor to add soft delete to existing database

-- Add deleted_at columns to existing tables
ALTER TABLE public.breathing_exercises ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
ALTER TABLE public.breath_phases ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
ALTER TABLE public.training_results ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- Create indexes for deleted_at columns
CREATE INDEX IF NOT EXISTS idx_breathing_exercises_deleted_at ON public.breathing_exercises(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_breath_phases_deleted_at ON public.breath_phases(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_training_results_deleted_at ON public.training_results(deleted_at) WHERE deleted_at IS NOT NULL;

-- Update RLS policies to exclude deleted records
DROP POLICY IF EXISTS "Users can view their own exercises" ON public.breathing_exercises;
CREATE POLICY "Users can view their own exercises" ON public.breathing_exercises
    FOR SELECT USING (auth.uid() = user_id AND deleted_at IS NULL);

DROP POLICY IF EXISTS "Users can update their own exercises" ON public.breathing_exercises;
CREATE POLICY "Users can update their own exercises" ON public.breathing_exercises
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view phases of their exercises" ON public.breath_phases;
CREATE POLICY "Users can view phases of their exercises" ON public.breath_phases
    FOR SELECT USING (
        breath_phases.deleted_at IS NULL AND 
        EXISTS (
            SELECT 1 FROM public.breathing_exercises 
            WHERE breathing_exercises.id = breath_phases.exercise_id 
            AND breathing_exercises.user_id = auth.uid()
            AND breathing_exercises.deleted_at IS NULL
        )
    );

DROP POLICY IF EXISTS "Users can update their own phases" ON public.breath_phases;
CREATE POLICY "Users can update their own phases" ON public.breath_phases
    FOR UPDATE USING (exercise_user_id = auth.uid()) WITH CHECK (exercise_user_id = auth.uid());

DROP POLICY IF EXISTS "Users can view their own training results" ON public.training_results;
CREATE POLICY "Users can view their own training results" ON public.training_results
    FOR SELECT USING (auth.uid() = user_id AND deleted_at IS NULL);

DROP POLICY IF EXISTS "Users can update their own training results" ON public.training_results;
CREATE POLICY "Users can update their own training results" ON public.training_results
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

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

-- Enable pg_cron extension (if not already enabled)
-- Run this only if pg_cron is not already enabled in your project
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule the cleanup function to run daily at 2 AM
-- Uncomment the line below after enabling pg_cron extension
-- SELECT cron.schedule('cleanup-deleted-records', '0 2 * * *', 'SELECT public.cleanup_deleted_records();');

-- Test the cleanup function (optional - remove this line in production)
-- SELECT public.cleanup_deleted_records();
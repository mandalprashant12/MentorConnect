-- ============================================================
--  AUTO-PROVISION DIRECT CHAT THREADS
--  Creates a 'direct' chat_thread between a mentor and mentee
--  if one does not already exist. Uses SECURITY DEFINER to
--  bypass RLS, allowing the "message any mentor" feature.
-- ============================================================

CREATE OR REPLACE FUNCTION provision_direct_chat_thread(
    p_mentor_id UUID,
    p_mentee_id UUID
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_thread_id UUID;
BEGIN
    -- Check if thread already exists
    SELECT id INTO v_thread_id
    FROM chat_threads
    WHERE thread_type = 'direct'
      AND mentor_id = p_mentor_id
      AND mentee_id = p_mentee_id;

    IF v_thread_id IS NOT NULL THEN
        RETURN v_thread_id;
    END IF;

    -- Create the thread
    INSERT INTO chat_threads (
        thread_type,
        mentor_id,
        mentee_id,
        group_id,
        title,
        created_by
    )
    VALUES (
        'direct'::chat_thread_type,
        p_mentor_id,
        p_mentee_id,
        NULL,
        NULL,
        p_mentee_id
    )
    ON CONFLICT (thread_type, mentor_id, mentee_id) DO UPDATE
        SET updated_at = NOW()
    RETURNING id INTO v_thread_id;

    RETURN v_thread_id;
END;
$$;

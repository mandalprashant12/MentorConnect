-- ============================================================
-- AUTO-UPDATE CHAT THREAD TIMESTAMP ON NEW MESSAGES
-- Ensures that sorting chats by newest messages works correctly.
-- ============================================================

CREATE OR REPLACE FUNCTION update_chat_thread_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE chat_threads
    SET updated_at = NOW()
    WHERE id = NEW.thread_id;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_update_chat_thread_timestamp ON chat_messages;
CREATE TRIGGER trigger_update_chat_thread_timestamp
AFTER INSERT ON chat_messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_thread_timestamp();

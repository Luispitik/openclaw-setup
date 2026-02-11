-- ============================================================
--  OpenClaw - Indexes and Triggers (SQLite)
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_proposals_status ON proposals(status);
CREATE INDEX IF NOT EXISTS idx_proposals_agent ON proposals(agent_id);
CREATE INDEX IF NOT EXISTS idx_missions_status ON missions(status);
CREATE INDEX IF NOT EXISTS idx_steps_status ON mission_steps(status);
CREATE INDEX IF NOT EXISTS idx_steps_mission ON mission_steps(mission_id);
CREATE INDEX IF NOT EXISTS idx_events_created ON agent_events(created_at);
CREATE INDEX IF NOT EXISTS idx_events_agent ON agent_events(agent_id);
CREATE INDEX IF NOT EXISTS idx_memory_agent ON agent_memory(agent_id);
CREATE INDEX IF NOT EXISTS idx_triggers_enabled ON trigger_rules(enabled);
CREATE INDEX IF NOT EXISTS idx_reactions_status ON agent_reactions(status);
CREATE INDEX IF NOT EXISTS idx_runs_type ON action_runs(action_type);
CREATE INDEX IF NOT EXISTS idx_insights_agent ON agent_insights(agent_id);

-- Auto-update timestamps via triggers
CREATE TRIGGER IF NOT EXISTS agents_updated
  AFTER UPDATE ON agents
  FOR EACH ROW
  BEGIN
    UPDATE agents SET updated_at = datetime('now') WHERE id = NEW.id;
  END;

CREATE TRIGGER IF NOT EXISTS policies_updated
  AFTER UPDATE ON policies
  FOR EACH ROW
  BEGIN
    UPDATE policies SET updated_at = datetime('now') WHERE key = NEW.key;
  END;

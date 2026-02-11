-- ============================================================
--  OpenClaw Multi-Agent System - Database Schema (SQLite)
--  Local database: ~/.openclaw/data/openclaw.db
-- ============================================================

CREATE TABLE IF NOT EXISTS agents (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  name TEXT NOT NULL UNIQUE,
  display_name TEXT,
  role TEXT NOT NULL,
  status TEXT DEFAULT 'idle' CHECK (status IN ('idle', 'active', 'blocked')),
  level INTEGER DEFAULT 1 CHECK (level BETWEEN 1 AND 4),
  session_key TEXT NOT NULL,
  current_task_id TEXT,
  default_model TEXT DEFAULT 'gemini-2.5-flash',
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS proposals (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  agent_id TEXT REFERENCES agents(id),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  proposed_steps TEXT DEFAULT '[]',
  source TEXT DEFAULT 'api' CHECK (source IN ('api', 'trigger', 'reaction', 'agent', 'human', 'setup')),
  rejection_reason TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  reviewed_at TEXT
);

CREATE TABLE IF NOT EXISTS missions (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  proposal_id TEXT REFERENCES proposals(id),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'approved' CHECK (status IN ('approved', 'running', 'succeeded', 'failed', 'cancelled')),
  created_by TEXT REFERENCES agents(id),
  assigned_to TEXT DEFAULT '[]',
  priority INTEGER DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
  created_at TEXT DEFAULT (datetime('now')),
  started_at TEXT,
  completed_at TEXT
);

CREATE TABLE IF NOT EXISTS mission_steps (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  mission_id TEXT REFERENCES missions(id) ON DELETE CASCADE,
  kind TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'queued' CHECK (status IN ('queued', 'running', 'succeeded', 'failed', 'skipped')),
  payload TEXT DEFAULT '{}',
  result TEXT,
  error_message TEXT,
  reserved_by TEXT,
  reserved_at TEXT,
  step_order INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now')),
  completed_at TEXT
);

CREATE TABLE IF NOT EXISTS agent_events (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  agent_id TEXT REFERENCES agents(id),
  kind TEXT NOT NULL,
  title TEXT NOT NULL,
  summary TEXT,
  tags TEXT DEFAULT '[]',
  metadata TEXT DEFAULT '{}',
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS agent_memory (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  agent_id TEXT REFERENCES agents(id),
  type TEXT NOT NULL CHECK (type IN ('insight', 'pattern', 'strategy', 'preference', 'lesson')),
  content TEXT NOT NULL,
  confidence REAL DEFAULT 0.60 CHECK (confidence BETWEEN 0 AND 1),
  tags TEXT DEFAULT '[]',
  source_trace_id TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS policies (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT '{}',
  description TEXT,
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS trigger_rules (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  trigger_event TEXT NOT NULL,
  conditions TEXT DEFAULT '{}',
  action_config TEXT DEFAULT '{}',
  target_agent TEXT,
  cooldown_minutes INTEGER DEFAULT 60,
  enabled INTEGER DEFAULT 0,
  fire_count INTEGER DEFAULT 0,
  last_fired_at TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS agent_reactions (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  source_event_id TEXT REFERENCES agent_events(id),
  source_agent_id TEXT REFERENCES agents(id),
  target_agent_id TEXT REFERENCES agents(id),
  reaction_type TEXT NOT NULL,
  context TEXT DEFAULT '{}',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'skipped')),
  created_at TEXT DEFAULT (datetime('now')),
  processed_at TEXT
);

CREATE TABLE IF NOT EXISTS action_runs (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  action_type TEXT NOT NULL,
  started_at TEXT DEFAULT (datetime('now')),
  completed_at TEXT,
  duration_ms INTEGER,
  result TEXT DEFAULT '{}',
  errors TEXT DEFAULT '[]',
  metadata TEXT DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS agent_insights (
  id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(2)) || '-' || hex(randomblob(6)))),
  agent_id TEXT REFERENCES agents(id),
  insight_type TEXT NOT NULL CHECK (insight_type IN ('discovery', 'pattern', 'strategy')),
  content TEXT NOT NULL,
  confidence REAL DEFAULT 0.50,
  upvotes INTEGER DEFAULT 0,
  promoted INTEGER DEFAULT 0,
  promoted_at TEXT,
  source_mission_id TEXT REFERENCES missions(id),
  created_at TEXT DEFAULT (datetime('now'))
);

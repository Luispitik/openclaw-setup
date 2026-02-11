-- ============================================================
--  OpenClaw - Initial Data (Agents, Policies, Triggers)
-- ============================================================

INSERT OR IGNORE INTO agents (name, display_name, role, session_key, level, default_model) VALUES
('cami', 'Cami', 'CEO - Coordinadora General', 'agent:cami:main', 3, 'gemini-2.5-pro');
INSERT OR IGNORE INTO agents (name, display_name, role, session_key, level, default_model) VALUES
('dev_agent', 'Dev', 'Desarrollador Principal', 'agent:dev_agent:main', 2, 'codex-5.2');
INSERT OR IGNORE INTO agents (name, display_name, role, session_key, level, default_model) VALUES
('research_agent', 'Rex', 'Analista de Investigacion', 'agent:research_agent:main', 2, 'gemini-2.5-pro');
INSERT OR IGNORE INTO agents (name, display_name, role, session_key, level, default_model) VALUES
('content_agent', 'Sage', 'Creador de Contenido', 'agent:content_agent:main', 2, 'gemini-2.5-pro');
INSERT OR IGNORE INTO agents (name, display_name, role, session_key, level, default_model) VALUES
('security_agent', 'Shield', 'Monitor de Seguridad', 'agent:security_agent:main', 2, 'gemini-2.5-flash');

INSERT OR IGNORE INTO policies (key, value, description) VALUES
('auto_approve', '{"enabled": true, "allowed_step_kinds": ["analyze", "research", "draft", "review", "summarize", "scan", "crawl"]}', 'Tareas de bajo riesgo que se aprueban solas');
INSERT OR IGNORE INTO policies (key, value, description) VALUES
('model_routing', '{"default": "gemini-2.5-flash", "code": "codex-5.2", "complex": "gemini-3-pro", "medium": "gemini-2.5-pro"}', 'Que cerebro usar para cada tipo de tarea');
INSERT OR IGNORE INTO policies (key, value, description) VALUES
('daily_limits', '{"max_proposals_per_agent": 20, "max_missions_per_agent": 10, "max_steps_per_mission": 10}', 'Limites diarios para no gastar demasiado');
INSERT OR IGNORE INTO policies (key, value, description) VALUES
('heartbeat', '{"interval_minutes": 5, "model": "gemini-2.5-flash", "timeout_seconds": 30}', 'Configuracion del latido del sistema');
INSERT OR IGNORE INTO policies (key, value, description) VALUES
('worker_policy', '{"enabled": true, "executor": "vps", "stale_threshold_minutes": 30}', 'Politica de ejecucion de tareas');
INSERT OR IGNORE INTO policies (key, value, description) VALUES
('cost_alerts', '{"daily_trigger_limit": 50, "daily_reaction_limit": 30}', 'Alertas si se gasta demasiado');
INSERT OR IGNORE INTO policies (key, value, description) VALUES
('reaction_matrix', '{"patterns": [{"source": "*", "tags": ["mission","failed"], "target": "cami", "type": "diagnose", "probability": 1.0, "cooldown": 60}, {"source": "*", "tags": ["blocked"], "target": "cami", "type": "unblock", "probability": 1.0, "cooldown": 30}, {"source": "content_agent", "tags": ["content","published"], "target": "research_agent", "type": "review", "probability": 0.5, "cooldown": 120}, {"source": "research_agent", "tags": ["research","completed"], "target": "content_agent", "type": "create", "probability": 0.3, "cooldown": 180}]}', 'Como reaccionan los agentes entre si');

INSERT OR IGNORE INTO trigger_rules (name, trigger_event, conditions, action_config, target_agent, cooldown_minutes, enabled, description) VALUES
('mission_failed_diagnosis', 'mission_status_changed', '{"new_status": "failed"}', '{"proposal_type": "diagnose"}', 'cami', 60, 0, 'Si una mision falla, Cami investiga por que');
INSERT OR IGNORE INTO trigger_rules (name, trigger_event, conditions, action_config, target_agent, cooldown_minutes, enabled, description) VALUES
('agent_blocked_escalation', 'agent_status_changed', '{"new_status": "blocked"}', '{"proposal_type": "unblock"}', 'cami', 30, 0, 'Si un agente se atasca, Cami intenta ayudar');
INSERT OR IGNORE INTO trigger_rules (name, trigger_event, conditions, action_config, target_agent, cooldown_minutes, enabled, description) VALUES
('proactive_scan_signals', 'heartbeat', '{"interval_hours": 3}', '{"proposal_type": "scan"}', 'research_agent', 180, 0, 'Rex busca noticias cada 3 horas');
INSERT OR IGNORE INTO trigger_rules (name, trigger_event, conditions, action_config, target_agent, cooldown_minutes, enabled, description) VALUES
('proactive_draft_content', 'heartbeat', '{"interval_hours": 4}', '{"proposal_type": "draft"}', 'content_agent', 240, 0, 'Sage prepara borradores cada 4 horas');
INSERT OR IGNORE INTO trigger_rules (name, trigger_event, conditions, action_config, target_agent, cooldown_minutes, enabled, description) VALUES
('proactive_code_review', 'heartbeat', '{"interval_hours": 4}', '{"proposal_type": "review"}', 'dev_agent', 240, 0, 'Dev revisa codigo cada 4 horas');
INSERT OR IGNORE INTO trigger_rules (name, trigger_event, conditions, action_config, target_agent, cooldown_minutes, enabled, description) VALUES
('proactive_analyze_ops', 'heartbeat', '{"interval_hours": 8}', '{"proposal_type": "analyze"}', 'cami', 480, 0, 'Cami analiza operaciones cada 8 horas');

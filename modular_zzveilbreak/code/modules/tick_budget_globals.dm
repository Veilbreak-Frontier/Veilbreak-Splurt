// Centralized tick-budget globals for modular tick-safe overrides

// Time budget (seconds) reserved for massdelete processing per slice
// Centralized tick-budget globals (use GLOBAL_VAR_INIT to be safe across load order)
GLOBAL_VAR_INIT(modular_massdelete_time_budget, 0.02)
GLOBAL_VAR_INIT(modular_reload_time_budget, 0.02)
GLOBAL_VAR_INIT(modular_time_budget_buffer, 0.005)

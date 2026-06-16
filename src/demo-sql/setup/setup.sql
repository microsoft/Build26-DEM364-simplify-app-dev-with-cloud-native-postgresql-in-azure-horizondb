-- ---------------------------------------------------------------------------
-- Required extensions.
--
-- These must first be enabled on the HorizonDB server via a parameter group
-- (azure.extensions, and shared_preload_libraries for those that need
-- preloading such as pg_durable / pg_fts). If an extension is not allow-listed,
-- CREATE EXTENSION fails. See:
--   https://learn.microsoft.com/en-us/azure/horizondb/extensions/how-to-load-libraries
--   https://learn.microsoft.com/en-us/azure/horizondb/extensions/how-to-allow-extensions
--   https://learn.microsoft.com/en-us/azure/horizondb/extensions/how-to-create-extensions
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pg_durable;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS azure_ai;
CREATE EXTENSION IF NOT EXISTS pg_fts;
CREATE EXTENSION IF NOT EXISTS pg_diskann;
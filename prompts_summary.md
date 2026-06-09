# Consolidated Prompt: Tasty Bytes Data Pipeline

Based on the tables in LARSR_DB.RAW, build a complete dbt project implementing a medallion architecture (bronze/silver/gold) with optimized materializations (views for staging, dynamic tables for intermediate, tables for marts). The most downstream artifact should be a Snowflake semantic view defined in YAML format, deployed via SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML.

## Requirements

1. Investigate data volumes and join cardinality at each stage to avoid exploding joins before building.
2. Use Jinja `source()` and `ref()` throughout — no hardcoded databases or schemas in SQL models.
3. Configure profiles.yml with two targets: dev (schema: DEV_LARSR_TASTY_BYTES) and prod (schema: PROD_TASTY_BYTES), both in LARSR_DB.
4. The semantic model YAML must have a single unambiguous path to each metric (no competing tables with overlapping revenue definitions). Include metric comments, synonyms, and verified queries for key board-level questions.
5. Create a separate dev copy of the semantic YAML pointing to the dev schema (since YAML can't be parameterized).
6. Create a metrics sign-off document (YAML) aligned with the semantic model, suitable for stakeholder approval — including metric name, synonyms, definition, formula, unit, grain, source tables, and approval fields.
7. Deploy the dbt project as a Snowflake dbt project object with a scheduled task to rebuild marts every weekday at 7 AM UTC (via EXECUTE DBT PROJECT in a Snowflake Task).
8. Create a Cortex Agent in the dev schema using the dev semantic view, with text-to-SQL and data-to-chart tools.
9. Create an MCP server exposing both the Cortex Analyst semantic view and the Cortex Agent as tools.
10. Generate a PAT for authenticating external MCP clients.
11. Add a .gitignore for target/, logs/, dbt_packages/, package-lock.yml, .user.yml.
12. Ask Cortex Analyst a board-level question (e.g., annual revenue trend, gross margin, regional growth drivers) to validate the semantic view works end-to-end.
13. Save a session summary documenting all decisions, cardinality analysis, and architecture.

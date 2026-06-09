Based on the tables in larsrdb.raw build a dbt project to load a semantic view that users will access with Snowflake Cortex to get qualified business insight.
The semantic view should be the most downstream part of a medaillon architecture dbt project.
The semantic view shall be defined as a semantic model in dbt yml syntax and materialized as a snowflake semantic view.
In addition to generate the dbt project, create a signoff version of metrics in a format suitable to be signed by stakeholders.
Optimize materialization of the models of the different stages - views, tables, dynamic tables. 